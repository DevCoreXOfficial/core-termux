/**
 * bun-android-shim.c — LD_PRELOAD shim for Bun on Android/Termux
 *
 * Dual purpose:
 *
 * 1. opendir/openat64 interception for bionic:
 *    Bun's project-root discovery traverses up the directory tree.
 *    On Termux, Android's sandbox makes /data/ and /data/data/
 *    readable at the syscall level but returns "Permission denied"
 *    or causes Bun to abort with "Cannot read directory /data/".
 *    This shim intercepts opendir/openat64 and returns ENOENT
 *    for these paths, so Bun's traversal stops at the sandbox
 *    boundary instead of crashing.
 *
 * 2. mmap fix for compiled standalone binaries:
 *    `bun build --compile` produces ELF binaries where the embedded
 *    Bun runtime contains hardcoded (non-relocated) absolute pointers
 *    to the `.bun` section and other data sections (e.g., 0x5730000).
 *    On PIE loading, these addresses are never mapped, causing SEGFAULT.
 *    The constructor maps critical sections at their ELF virtual addresses
 *    via MAP_FIXED so the pointers resolve correctly.
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdarg.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <errno.h>
#include <dlfcn.h>
#include <dirent.h>

/* ================================================================
 * PART 1: opendir/openat64 interception
 * ================================================================ */

/* Paths to block — any path starting with these is denied */
static const char *blocked_prefixes[] = {
    "/data/",
    "/data/data/",
    NULL
};

/* Original functions (resolved via dlsym) */
typedef DIR *(*opendir_fn_t)(const char *);
typedef int (*openat64_fn_t)(int, const char *, int, ...);
static opendir_fn_t real_opendir = NULL;
static openat64_fn_t real_openat64 = NULL;

static int should_block(const char *path) {
    if (!path) return 0;
    for (int i = 0; blocked_prefixes[i]; i++) {
        if (strncmp(path, blocked_prefixes[i], strlen(blocked_prefixes[i])) == 0) {
            /* Don't block if it's the Termux sandbox itself */
            if (strncmp(path, "/data/data/com.termux", 21) == 0)
                return 0;
            return 1;
        }
    }
    return 0;
}

DIR *opendir(const char *path) {
    if (!real_opendir) {
        real_opendir = (opendir_fn_t)dlsym(RTLD_NEXT, "opendir");
    }
    if (should_block(path)) {
        errno = ENOENT;
        return NULL;
    }
    return real_opendir(path);
}

int openat64(int fd, const char *path, int flags, ...) {
    if (!real_openat64) {
        real_openat64 = (openat64_fn_t)dlsym(RTLD_NEXT, "openat64");
    }
    if (should_block(path)) {
        errno = ENOENT;
        return -1;
    }
    /* Pass mode if O_CREAT is set */
    mode_t mode = 0;
    if (flags & O_CREAT) {
        va_list ap;
        va_start(ap, flags);
        mode = (mode_t)va_arg(ap, int);
        va_end(ap);
    }
    return real_openat64(fd, path, flags, mode);
}


/* ================================================================
 * getcwd fallback — Android's getcwd() fails with
 * "CouldntReadCurrentDirectory" when the process was started via
 * execv() with a relative cwd.  Read /proc/self/cwd as fallback.
 * ================================================================ */

typedef char *(*getcwd_fn_t)(char *, size_t);
static getcwd_fn_t real_getcwd = NULL;

char *getcwd(char *buf, size_t size) {
    if (!real_getcwd)
        real_getcwd = (getcwd_fn_t)dlsym(RTLD_NEXT, "getcwd");

    /* Try real getcwd first */
    char *result = real_getcwd(buf, size);
    if (result) return result;

    /* Fallback: read /proc/self/cwd symlink */
    ssize_t len = readlink("/proc/self/cwd", buf, size - 1);
    if (len < 0) return NULL;
    buf[len] = '\0';
    return buf;
}


/* ================================================================
 * PART 2: linkat/link → copy fallback
 *
 * Android restricts hardlink creation across mount points and app
 * sandboxes.  Bun's installer tries linkat() first; when the kernel
 * returns EACCES/EPERM, Bun aborts instead of falling back to copy.
 * This interception converts hardlink requests into copy_file_range
 * (or read+write fallback), so Bun's install flow succeeds.
 * ================================================================ */

#include <sys/sendfile.h>

static int copy_file(const char *src, const char *dst) {
    int fd_in = open(src, O_RDONLY);
    if (fd_in < 0) return -1;

    struct stat st;
    if (fstat(fd_in, &st) < 0) { close(fd_in); return -1; }

    int fd_out = open(dst, O_WRONLY | O_CREAT | O_TRUNC, st.st_mode);
    if (fd_out < 0) { close(fd_in); return -1; }

    ssize_t sent = 0;
    off_t offset = 0;
    while (offset < st.st_size) {
        sent = sendfile(fd_out, fd_in, &offset, st.st_size - offset);
        if (sent <= 0) break;
    }

    close(fd_in);
    close(fd_out);
    return (offset == st.st_size) ? 0 : -1;
}

int linkat(int olddirfd, const char *oldpath,
           int newdirfd, const char *newpath, int flags) {
    /* Resolve absolute paths for copy fallback */
    char src[PATH_MAX], dst[PATH_MAX];

    if (oldpath && oldpath[0] != '/') {
        char dir[PATH_MAX];
        if (olddirfd == AT_FDCWD) {
            if (getcwd(dir, sizeof(dir)) == NULL) return -1;
        } else {
            char fdpath[32];
            snprintf(fdpath, sizeof(fdpath), "/proc/self/fd/%d", olddirfd);
            ssize_t n = readlink(fdpath, dir, sizeof(dir) - 1);
            if (n < 0) return -1;
            dir[n] = '\0';
        }
        snprintf(src, sizeof(src), "%s/%s", dir, oldpath);
    } else {
        snprintf(src, sizeof(src), "%s", oldpath ? oldpath : "");
    }

    if (newpath && newpath[0] != '/') {
        char dir[PATH_MAX];
        if (newdirfd == AT_FDCWD) {
            if (getcwd(dir, sizeof(dir)) == NULL) return -1;
        } else {
            char fdpath[32];
            snprintf(fdpath, sizeof(fdpath), "/proc/self/fd/%d", newdirfd);
            ssize_t n = readlink(fdpath, dir, sizeof(dir) - 1);
            if (n < 0) return -1;
            dir[n] = '\0';
        }
        snprintf(dst, sizeof(dst), "%s/%s", dir, newpath);
    } else {
        snprintf(dst, sizeof(dst), "%s", newpath ? newpath : "");
    }

    return copy_file(src, dst);
}

int link(const char *oldpath, const char *newpath) {
    return copy_file(oldpath, newpath);
}

/* ================================================================
 * PART 3: mmap fix for compiled standalone binaries
 * ================================================================ */

/* ELF64 structures */
typedef struct {
    unsigned char e_ident[16];
    uint16_t e_type;
    uint16_t e_machine;
    uint32_t e_version;
    uint64_t e_entry;
    uint64_t e_phoff;
    uint64_t e_shoff;
    uint32_t e_flags;
    uint16_t e_ehsize;
    uint16_t e_phentsize;
    uint16_t e_phnum;
    uint16_t e_shentsize;
    uint16_t e_shnum;
    uint16_t e_shstrndx;
} Elf64_Ehdr;

typedef struct {
    uint32_t sh_name;
    uint32_t sh_type;
    uint64_t sh_flags;
    uint64_t sh_addr;
    uint64_t sh_offset;
    uint64_t sh_size;
    uint32_t sh_link;
    uint32_t sh_info;
    uint64_t sh_addralign;
    uint64_t sh_entsize;
} Elf64_Shdr;

/* Known hardcoded addresses in Bun standalone binaries
 * These are the ELF virtual addresses that Bun's embedded runtime
 * references with non-relocated absolute pointers.
 * Add more as discovered from crash reports. */
static const uint64_t known_addresses[] = {
    0x5730000,  /* .bun section — embedded source code metadata */
};
static const int num_known_addresses =
    sizeof(known_addresses) / sizeof(known_addresses[0]);

static inline uint64_t page_align_down(uint64_t addr) {
    return addr & ~(uint64_t)(0xFFF);
}

static inline uint64_t page_align_up(uint64_t addr) {
    return (addr + 0xFFF) & ~(uint64_t)(0xFFF);
}

/* Find a section by name in the section header string table */
static int find_section_by_name(int fd, const Elf64_Ehdr *ehdr,
                                 const char *name, Elf64_Shdr *out) {
    if (ehdr->e_shstrndx >= ehdr->e_shnum) return -1;

    /* Read section header string table */
    Elf64_Shdr shstrtab;
    if (lseek(fd, ehdr->e_shoff + ehdr->e_shstrndx * ehdr->e_shentsize,
              SEEK_SET) < 0) return -1;
    if (read(fd, &shstrtab, sizeof(shstrtab)) != sizeof(shstrtab)) return -1;

    char *strtab = malloc(shstrtab.sh_size);
    if (!strtab) return -1;
    if (lseek(fd, shstrtab.sh_offset, SEEK_SET) < 0) { free(strtab); return -1; }
    if (read(fd, strtab, shstrtab.sh_size) != (ssize_t)shstrtab.sh_size) {
        free(strtab); return -1;
    }

    Elf64_Shdr shdr;
    int found = 0;
    for (int i = 0; i < ehdr->e_shnum; i++) {
        if (lseek(fd, ehdr->e_shoff + i * ehdr->e_shentsize, SEEK_SET) < 0) break;
        if (read(fd, &shdr, sizeof(shdr)) != sizeof(shdr)) break;

        const char *sname = (shdr.sh_name < shstrtab.sh_size)
                            ? strtab + shdr.sh_name : "";
        if (strcmp(sname, name) == 0) {
            memcpy(out, &shdr, sizeof(shdr));
            found = 1;
            break;
        }
    }
    free(strtab);
    return found ? 0 : -1;
}

/* Map a section at its virtual address with MAP_FIXED */
static int map_section_at_vaddr(int fd, const Elf64_Shdr *shdr) {
    uint64_t map_addr = page_align_down(shdr->sh_addr);
    uint64_t map_end = page_align_up(shdr->sh_addr + shdr->sh_size);
    uint64_t map_size = map_end - map_addr;

    if (shdr->sh_type == 8) { /* SHT_NOBITS */
        void *addr = mmap((void *)(uintptr_t)map_addr, map_size,
                          PROT_READ | PROT_WRITE,
                          MAP_PRIVATE | MAP_FIXED | MAP_ANONYMOUS, -1, 0);
        return (addr == MAP_FAILED) ? -1 : 0;
    }

    /* PROGBITS: map from file */
    uint64_t file_off = shdr->sh_offset - (shdr->sh_addr - map_addr);
    void *addr = mmap((void *)(uintptr_t)map_addr, map_size, PROT_READ,
                      MAP_PRIVATE | MAP_FIXED, fd, file_off);
    return (addr == MAP_FAILED) ? -1 : 0;
}

/* Constructor: fix compiled standalone binaries */
static void fix_bun_standalone(void) {
    const char *exe_path = "/proc/self/exe";
    int fd = open(exe_path, O_RDONLY);
    if (fd < 0) {
        char cmdline[256];
        int cfd = open("/proc/self/cmdline", O_RDONLY);
        if (cfd >= 0) {
            int n = read(cfd, cmdline, sizeof(cmdline) - 1);
            close(cfd);
            if (n > 0) {
                cmdline[n] = '\0';
                fd = open(cmdline, O_RDONLY);
            }
        }
        if (fd < 0) return;
    }

    Elf64_Ehdr ehdr;
    if (read(fd, &ehdr, sizeof(ehdr)) != sizeof(ehdr)) { close(fd); return; }

    /* Verify ELF64 */
    if (ehdr.e_ident[0] != 0x7f || ehdr.e_ident[1] != 'E' ||
        ehdr.e_ident[2] != 'L' || ehdr.e_ident[3] != 'F') { close(fd); return; }
    if (ehdr.e_ident[4] != 2) { close(fd); return; }
    if (ehdr.e_shentsize != sizeof(Elf64_Shdr)) { close(fd); return; }

    /* Try to find and map the .bun section */
    Elf64_Shdr bun;
    if (find_section_by_name(fd, &ehdr, ".bun", &bun) == 0) {
        map_section_at_vaddr(fd, &bun);
    }

    /* Try known absolute addresses (fallback) */
    for (int i = 0; i < num_known_addresses; i++) {
        uint64_t vaddr = known_addresses[i];
        /* Check if already mapped by section name above */
        if (bun.sh_addr == vaddr && bun.sh_size > 0) continue;

        /* Try direct mmap from file (vaddr == file offset in bun binaries) */
        uint64_t pg = page_align_down(vaddr);
        mmap((void *)(uintptr_t)pg, 0x1000, PROT_READ,
             MAP_PRIVATE | MAP_FIXED, fd, pg);
    }

    close(fd);
}

/* Constructor runs at process start — handles both fixes */
__attribute__((constructor(1)))
static void init(void) {
    fix_bun_standalone();
}
