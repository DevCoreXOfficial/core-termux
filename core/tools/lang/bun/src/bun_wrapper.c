/*
 * bun_wrapper.c — wrapper for Android-native Bun on Termux
 *
 * Two workarounds:
 * 1. Relative path resolution: realpath() resolves relative file/dir
 *    arguments to absolute before exec'ing bun, working around
 *    Android Bun's CouldntReadCurrentDirectory issue.
 * 2. LD_PRELOAD shim (bun-android-shim.so): intercepts opendir/openat64
 *    for /data/ and /data/data/, making them appear non-existent so
 *    Bun's project-root directory traversal stops at the sandbox
 *    boundary instead of failing with "Cannot read directory /data/".
 *    This enables bun build on Termux.
 *
 * Bun runs natively on bionic (Android's libc) via /system/bin/linker64.
 * No glibc, ld-linux, or complex syscall interception needed.
 *
 * Compiled with: clang -O2 -o bun bun_wrapper.c
 */
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char **argv) {
    /* BUN_REAL_BIN is substituted at install time */
    static const char bun_real_path[] = "__BUN_REAL__";

    /* LD_PRELOAD shim to block directory traversal above /data/data/com.termux/ */
    static const char shim_path[] = "__BUN_SHIM__";
    setenv("LD_PRELOAD", shim_path, 1);

    /* Termux-friendly environment for Android Bun */
    setenv("SSL_CERT_FILE",
           "/data/data/com.termux/files/usr/etc/tls/cert.pem", 0);
    setenv("TMPDIR", "/data/data/com.termux/files/usr/tmp", 0);
    setenv("HOME", "/data/data/com.termux/files/home", 0);
    setenv("BUN_INSTALL_CACHE_DIR",
           "/data/data/com.termux/files/home/.bun/cache", 0);
    setenv("XDG_CACHE_HOME",
           "/data/data/com.termux/files/home/.cache", 0);
    setenv("BUN_MANIFEST_CACHE",
           "/data/data/com.termux/files/home/.cache/bun/manifest", 0);
    setenv("npm_config_cache",
           "/data/data/com.termux/files/home/.npm", 0);

    /*
     * Android restricts hardlink creation (EPERM/EACCES).
     * Force bun's package installer to use copyfile instead.
     */
    setenv("BUN_INSTALL_BACKEND", "copyfile", 1);

    /* Build new argv: [real_bun, resolved_args...] */
    char **new_argv = malloc((argc + 1) * sizeof(char *));
    if (!new_argv)
        return 1;
    new_argv[0] = (char *)bun_real_path;

    for (int i = 1; i < argc; i++) {
        const char *arg = argv[i];

        /*
         * Resolve relative paths that point to existing files or
         * directories. We skip absolute paths (starting with '/'),
         * flags (starting with '-'), and empty strings.
         *
         * For the rest, try realpath(). If it resolves, use the
         * absolute form. If not (non-existing file, package name,
         * script name from package.json), pass through unchanged.
         *
         * This works around the Android Bun issue where
         * getcwd() fails with "CouldntReadCurrentDirectory".
         */
        if (arg[0] != '/' && arg[0] != '-' && arg[0] != '\0') {
            char abs_path[PATH_MAX];
            if (realpath(arg, abs_path) != NULL) {
                new_argv[i] = strdup(abs_path);
                if (!new_argv[i]) {
                    free(new_argv);
                    return 1;
                }
                continue;
            }
        }
        new_argv[i] = argv[i];
    }
    new_argv[argc] = NULL;

    execv(bun_real_path, new_argv);
    perror("execv");
    free(new_argv);
    return 1;
}
