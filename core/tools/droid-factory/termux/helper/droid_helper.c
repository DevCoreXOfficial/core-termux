/**
 * droid_helper.c — glibc loader helper for Droid Factory (Factory CLI) binary
 *
 * The droid binary from downloads.factory.ai is compiled against glibc
 * (interpreter /lib/ld-linux-aarch64.so.1). Android Termux uses bionic
 * libc which is incompatible. The glibc-repo package provides glibc
 * under $PREFIX/glibc/ with the ld-linux dynamic linker.
 *
 * This helper uses glibc's own dynamic linker (ld-linux-aarch64.so.1)
 * to load the droid binary with --library-path pointing to the glibc
 * libraries, making the binary run natively on Termux.
 *
 * Architecture: only aarch64/arm64 is supported by Termux.
 */

#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

int main(int argc, char** argv) {
    // 1. Clear conflicting Android Bionic preloads and search paths
    unsetenv("LD_PRELOAD");
    unsetenv("LD_LIBRARY_PATH");

    // 2. Set SSL and environment for the glibc context
    setenv("SSL_CERT_FILE", "/data/data/com.termux/files/usr/etc/tls/cert.pem", 1);
    setenv("TMPDIR", "/data/data/com.termux/files/usr/tmp", 1);

    // 3. Construct paths for the glibc loader and the real droid binary
    char* loader = "/data/data/com.termux/files/usr/glibc/lib/ld-linux-aarch64.so.1";
    char real_bin[] = "/data/data/com.termux/files/home/.local/share/core-termux-data/droid-factory/droid";
    char lib_path[] = "/data/data/com.termux/files/usr/glibc/lib";

    // 4. Construct argument array for execv
    // Format: [loader, --library-path, lib_path, real_bin, ...original_args]
    char** new_argv = malloc((argc + 4) * sizeof(char*));
    if (!new_argv) {
        return 1;
    }

    new_argv[0] = loader;
    new_argv[1] = "--library-path";
    new_argv[2] = lib_path;
    new_argv[3] = real_bin;

    for (int i = 1; i < argc; i++) {
        new_argv[i + 3] = argv[i];
    }
    new_argv[argc + 3] = NULL;

    // 5. Execute the glibc loader to run the real droid binary
    execv(loader, new_argv);

    // If execv returns, an error occurred
    perror("execv");
    free(new_argv);
    return 1;
}
