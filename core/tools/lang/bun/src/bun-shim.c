/*
 * bun-shim.c — LD_PRELOAD shim for bun on Termux
 *
 * Intercepts syscalls to:
 * 1. Redirect Termux home paths so glibc-based bun can resolve CWD correctly
 * 2. Fix bun's child process execve: when bun tries to exec through ld-linux
 *    with a bare command name (e.g. "add"), insert --library-path, --preload,
 *    and the bun binary path so the child can find glibc and run correctly
 * Compiled with: clang -O2 -fPIC -shared -nostdlib -o bun-shim.so bun-shim.c
 */
#include <stdarg.h>
#include <fcntl.h>
#include <sys/syscall.h>
#include <unistd.h>

#define ENOENT 2

extern int *__errno_location(void);
#define errno (*__errno_location())

static long sc(long n, long a1, long a2, long a3, long a4, long a5, long a6) {
    register long x0 __asm__("x0") = a1;
    register long x1 __asm__("x1") = a2;
    register long x2 __asm__("x2") = a3;
    register long x3 __asm__("x3") = a4;
    register long x4 __asm__("x4") = a5;
    register long x5 __asm__("x5") = a6;
    register long r __asm__("x8") = n;
    __asm__ volatile("svc #0"
                     : "+r"(r), "+r"(x0), "+r"(x1), "+r"(x2), "+r"(x3),
                       "+r"(x4), "+r"(x5)
                     :
                     : "memory");
    return x0;
}
#define SOPENAT(d, p, f, m)                                                         \
    sc(SYS_openat, (long)(d), (long)(p), (long)(f), (long)(m), 0, 0)
#define SFSTATAT(d, p, b, f)                                                        \
    sc(SYS_newfstatat, (long)(d), (long)(p), (long)(b), (long)(f), 0, 0)
#define SACCESS(p, m)                                                               \
    sc(SYS_faccessat, (long)(AT_FDCWD), (long)(p), (long)(m), 0, 0, 0)
#define SREADLINKAT(d, p, b, s)                                                     \
    sc(SYS_readlinkat, (long)(d), (long)(p), (long)(b), (long)(s), 0, 0)
#define SEXECVE(p, a, e)                                                            \
    sc(SYS_execve, (long)(p), (long)(a), (long)(e), 0, 0, 0)

static const char *prefix = "/data/data/com.termux/files/home/";
static int home_fd = -1;

/* Paths for execve interception */
static const char *ld_path =
    "/data/data/com.termux/files/usr/glibc/lib/ld-linux-aarch64.so.1";
static const char *lib_path = "/data/data/com.termux/files/usr/glibc/lib";
static const char *shim_path = "/data/data/com.termux/files/usr/lib/bun-shim.so";
static const char *wrapper_path = "/data/data/com.termux/files/usr/bin/bun";
static const char *bun_real_path =
    "/data/data/com.termux/files/home/.local/share/core-termux-data/bun/bun.real";

static int streq(const char *a, const char *b) {
    while (*a && *b) {
        if (*a != *b)
            return 0;
        a++;
        b++;
    }
    return *a == *b;
}

static int slen(const char *s) {
    int l = 0;
    while (*s) {
        l++;
        s++;
    }
    return l;
}

static void scopy(char *d, const char *s) {
    while (*s)
        *d++ = *s++;
    *d = '\0';
}

__attribute__((constructor)) static void init(void) {
    home_fd = SOPENAT(AT_FDCWD, "/data/data/com.termux/files/home",
                      O_RDONLY | O_DIRECTORY | O_CLOEXEC, 0);
}

/* returns 1 for exact roots /, /data, /data/data (NOT subpaths) */
static int is_rooted(const char *p) {
    if (!p || p[0] != '/')
        return 0;
    if (p[1] == '\0')
        return 1;
    if (p[1] == 'd' && p[2] == 'a' && p[3] == 't' && p[4] == 'a') {
        if (p[5] == '\0' || (p[5] == '/' && p[6] == '\0'))
            return 1;
        if (p[5] == '/' && p[6] == 'd' && p[7] == 'a' && p[8] == 't' &&
            p[9] == 'a') {
            if (p[10] == '\0' || (p[10] == '/' && p[11] == '\0'))
                return 1;
        }
    }
    return 0;
}

/* returns 1 if path starts with prefix (is under home) */
static int under_home(const char *p) {
    if (!p)
        return 0;
    const char *a = prefix;
    const char *b = p;
    while (*a && *b && *a == *b) {
        a++;
        b++;
    }
    return *a == '\0' && (*b != '\0');
}

/* helper: raw-syscall to libc-style return (-1 + errno) */
static int set_errno(long r) {
    if (r >= 0)
        return (int)r;
    errno = (int)(-r);
    return -1;
}

/* Forward open/openat calls. For rooted paths under home, redirect relative to
 * home_fd. */
static int redirect_openat(int dirfd, const char *p, int flags, mode_t m) {
    if (p && p[0] == '/') {
        if (is_rooted(p) && home_fd >= 0)
            return set_errno(SOPENAT(home_fd, ".", flags, m));
        if (under_home(p) && home_fd >= 0)
            return set_errno(SOPENAT(
                home_fd,
                p + (sizeof("/data/data/com.termux/files/home/") - 1), flags,
                m));
    }
    return set_errno(SOPENAT(dirfd, p, flags, m));
}

int openat(int dirfd, const char *p, int flags, ...) {
    if (flags & O_CREAT) {
        va_list ap;
        va_start(ap, flags);
        mode_t m = va_arg(ap, mode_t);
        va_end(ap);
        return redirect_openat(dirfd, p, flags, m);
    }
    return redirect_openat(dirfd, p, flags, 0);
}
int openat64(int dirfd, const char *p, int flags, ...) {
    if (flags & O_CREAT) {
        va_list ap;
        va_start(ap, flags);
        mode_t m = va_arg(ap, mode_t);
        va_end(ap);
        return redirect_openat(dirfd, p, flags, m);
    }
    return redirect_openat(dirfd, p, flags, 0);
}
int open(const char *p, int flags, ...) {
    if (flags & O_CREAT) {
        va_list ap;
        va_start(ap, flags);
        mode_t m = va_arg(ap, mode_t);
        va_end(ap);
        return redirect_openat(AT_FDCWD, p, flags, m);
    }
    return redirect_openat(AT_FDCWD, p, flags, 0);
}
int open64(const char *p, int flags, ...) {
    if (flags & O_CREAT) {
        va_list ap;
        va_start(ap, flags);
        mode_t m = va_arg(ap, mode_t);
        va_end(ap);
        return redirect_openat(AT_FDCWD, p, flags, m);
    }
    return redirect_openat(AT_FDCWD, p, flags, 0);
}

/* stat/fstatat: redirect rooted paths under home to relative path */
static int redirect_stat(int dirfd, const char *p, struct stat *b, int fl) {
    if (p && p[0] == '/') {
        if (is_rooted(p) && home_fd >= 0)
            return set_errno(SFSTATAT(home_fd, ".", (long)b, fl));
        if (under_home(p) && home_fd >= 0)
            return set_errno(SFSTATAT(
                home_fd,
                p + (sizeof("/data/data/com.termux/files/home/") - 1),
                (long)b, fl));
    }
    return set_errno(SFSTATAT(dirfd, p, (long)b, fl));
}

int newfstatat(int dirfd, const char *p, struct stat *b, int fl) {
    return redirect_stat(dirfd, p, b, fl);
}
int fstatat64(int dirfd, const char *p, struct stat *b, int fl) {
    return redirect_stat(dirfd, p, b, fl);
}
int __fxstatat(int ver, int dirfd, const char *p, struct stat *b, int fl) {
    (void)ver;
    return redirect_stat(dirfd, p, b, fl);
}
int stat(const char *p, struct stat *b) {
    return redirect_stat(AT_FDCWD, p, b, 0);
}
int lstat(const char *p, struct stat *b) {
    return redirect_stat(AT_FDCWD, p, b, AT_SYMLINK_NOFOLLOW);
}
int fstatat(int dirfd, const char *p, struct stat *b, int fl) {
    return redirect_stat(dirfd, p, b, fl);
}

/* access/faccessat: redirect rooted paths under home */
static int redirect_access(const char *p, int mode) {
    if (p && p[0] == '/') {
        if (is_rooted(p))
            return set_errno(0); /* root is always accessible */
        if (under_home(p) && home_fd >= 0)
            return set_errno(SACCESS(
                p + (sizeof("/data/data/com.termux/files/home/") - 1), mode));
    }
    return set_errno(SACCESS(p, mode));
}

int faccessat(int dirfd, const char *p, int mode, int flags) {
    (void)dirfd;
    (void)flags;
    return redirect_access(p, mode);
}
int access(const char *p, int mode) {
    return redirect_access(p, mode);
}

/* readlinkat: intercept /proc/self/exe → return wrapper path */
ssize_t readlinkat(int dirfd, const char *path, char *buf, size_t bufsiz) {
    if (path && streq(path, "/proc/self/exe")) {
        int len = slen(wrapper_path);
        if (len < (int)bufsiz) {
            char *d = buf;
            const char *s = wrapper_path;
            while (*s)
                *d++ = *s++;
            *d = '\0';
        }
        return len;
    }
    return (ssize_t)SREADLINKAT(dirfd, path, buf, bufsiz);
}

/* execve: intercept bun's child process spawning
 *
 * Three fixes:
 * 1. bun constructs child execve as: execve(ld-linux, [ld-linux, "add", ...])
 *    where "add" is a subcommand name. Fix by inserting --library-path, --preload,
 *    and bun.real path.
 * 2. bun spawns child to exec .js/.ts scripts directly. Kernel returns ENOENT
 *    because there's no shebang. Fix by redirecting to bun.real via ld-linux.
 * 3. Strip LD_LIBRARY_PATH from envp for non-ld-linux execs. LD_LIBRARY_PATH
 *    pointing to glibc/lib confuses the Android linker when exec'ing Android
 *    binaries (like the bun wrapper itself). Since we use --library-path for
 *    glibc binaries, LD_LIBRARY_PATH is redundant. */

/* Build a new envp without LD_LIBRARY_PATH and LD_PRELOAD.
 * These glibc-specific env vars confuse the Android linker when exec'ing
 * bionic binaries. We use --library-path/--preload for glibc binaries instead.
 * Returns pointer to static buffer. */
static char **strip_glibc_env(char *const envp[]) {
    static char *clean[256];
    int j = 0;
    for (int i = 0; envp[i] && j < 255; i++) {
        const char *e = envp[i];
        /* Skip LD_LIBRARY_PATH=* */
        if (e[0] == 'L' && e[1] == 'D' && e[2] == '_' && e[3] == 'L' &&
            e[4] == 'I' && e[5] == 'B' && e[6] == 'R' && e[7] == 'A' &&
            e[8] == 'R' && e[9] == 'Y' && e[10] == '_' && e[11] == 'P' &&
            e[12] == 'A' && e[13] == 'T' && e[14] == 'H' && e[15] == '=')
            continue;
        /* Skip LD_PRELOAD=* */
        if (e[0] == 'L' && e[1] == 'D' && e[2] == '_' && e[3] == 'P' &&
            e[4] == 'R' && e[5] == 'E' && e[6] == 'L' && e[7] == 'O' &&
            e[8] == 'A' && e[9] == 'D' && e[10] == '=')
            continue;
        clean[j++] = envp[i];
    }
    clean[j] = 0;
    return clean;
}

int execve(const char *pathname, char *const argv[], char *const envp[]) {
    char **clean_env = strip_glibc_env(envp);

    /* Fix 1: ld-linux with bare command name */
    if (pathname && streq(pathname, ld_path) && bun_real_path && argv &&
        argv[1] && argv[1][0] != '/' && argv[1][0] != '-') {
        int argc = 0;
        while (argv[argc])
            argc++;

        char *new_argv[64];
        int i = 0;
        new_argv[i++] = (char *)pathname;
        new_argv[i++] = "--library-path";
        new_argv[i++] = (char *)lib_path;
        new_argv[i++] = "--preload";
        new_argv[i++] = (char *)shim_path;
        new_argv[i++] = (char *)bun_real_path;
        for (int j = 1; j <= argc; j++)
            new_argv[i++] = argv[j];
        new_argv[i] = NULL;

        return (int)SEXECVE(pathname, new_argv, envp);
    }

    /* Try the original execve (without LD_LIBRARY_PATH) */
    long r = SEXECVE(pathname, argv, clean_env);
    if (r >= 0)
        return (int)r;

    /* Fix 2: ENOENT on existing file = script without shebang → run via bun
     * through ld-linux (bun.real is a glibc binary that needs the loader) */
    int err = (int)(-r);
    if (err == ENOENT && bun_real_path && pathname) {
        long st_buf[64];
        if (SFSTATAT(AT_FDCWD, pathname, (long)st_buf, 0) >= 0) {
            int argc = 0;
            while (argv[argc])
                argc++;

            char *new_argv[64];
            int i = 0;
            new_argv[i++] = (char *)ld_path;
            new_argv[i++] = "--library-path";
            new_argv[i++] = (char *)lib_path;
            new_argv[i++] = "--preload";
            new_argv[i++] = (char *)shim_path;
            new_argv[i++] = (char *)bun_real_path;
            for (int j = 0; j <= argc; j++)
                new_argv[i++] = argv[j];
            new_argv[i] = NULL;

            return (int)SEXECVE(ld_path, new_argv, envp);
        }
    }

    errno = err;
    return -1;
}
