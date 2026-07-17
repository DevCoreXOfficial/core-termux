/*
 * bun-shim.c — LD_PRELOAD shim for bun on Termux
 *
 * Intercepts openat/stat/access syscalls to redirect Termux home paths
 * so the glibc-based bun binary can resolve CWD and file access correctly.
 * Compiled with: clang -O2 -fPIC -shared -nostdlib -o bun-shim.so bun-shim.c
 */
#include <stdarg.h>
#include <fcntl.h>
#include <sys/syscall.h>
#include <unistd.h>

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

static const char *prefix = "/data/data/com.termux/files/home/";
static int home_fd = -1;

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
