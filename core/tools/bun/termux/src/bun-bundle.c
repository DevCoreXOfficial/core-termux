/**
 * bun-bundle — Post-process a Bun compiled standalone binary for Android Termux.
 *
 * Bun's `bun build --compile` produces standalone ELF binaries that crash on
 * Android because the embedded Bun runtime contains hardcoded (non-relocated)
 * absolute pointers. This tool wraps the compiled binary with a shell script
 * that sets LD_PRELOAD to load the bun-android-shim.so fix library.
 *
 * Usage after bun build --compile:
 *   bun build --compile hello.ts
 *   bun-bundle hello
 *   ./hello     # Now works!
 *
 * The tool renames hello -> hello.bun and creates a shell wrapper hello.
 */
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <libgen.h>
#include <errno.h>
#include <sys/stat.h>

/* Default shim path on Termux */
#define DEFAULT_SHIM "/data/data/com.termux/files/usr/lib/bun-android-shim.so"

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: bun-bundle <compiled-binary> [shim-path]\n");
        fprintf(stderr, "\nPost-processes a Bun compiled binary to work on Android Termux.\n");
        fprintf(stderr, "Renames <binary> -> <binary>.bun and creates a shell wrapper.\n");
        fprintf(stderr, "\nExample:\n");
        fprintf(stderr, "  bun build --compile hello.ts\n");
        fprintf(stderr, "  bun-bundle hello\n");
        fprintf(stderr, "  ./hello   # Works!\n");
        return 1;
    }

    const char *binary = argv[1];
    const char *shim_path = (argc >= 3) ? argv[2] : DEFAULT_SHIM;

    /* Build the .bun filename: binary + ".bun" */
    size_t binlen = strlen(binary);
    char *bun_binary = malloc(binlen + 5);
    if (!bun_binary) { perror("malloc"); return 1; }
    memcpy(bun_binary, binary, binlen);
    memcpy(bun_binary + binlen, ".bun", 5);

    /* Check the original binary exists */
    if (access(binary, F_OK) < 0) {
        fprintf(stderr, "Error: %s not found\n", binary);
        free(bun_binary);
        return 1;
    }

    /* Rename binary -> binary.bun */
    if (rename(binary, bun_binary) < 0) {
        fprintf(stderr, "Error renaming %s -> %s: %s\n",
                binary, bun_binary, strerror(errno));
        free(bun_binary);
        return 1;
    }

    /* Get basename for the wrapper */
    char *bin_copy = strdup(binary);
    const char *base = basename(bin_copy);

    /* Create the shell wrapper */
    FILE *f = fopen(binary, "w");
    if (!f) {
        fprintf(stderr, "Error creating wrapper %s: %s\n",
                binary, strerror(errno));
        rename(bun_binary, binary);
        free(bun_binary);
        free(bin_copy);
        return 1;
    }

    fprintf(f, "#!/data/data/com.termux/files/usr/bin/bash\n");
    fprintf(f, "# Auto-generated wrapper for Bun compiled binary\n");
    fprintf(f, "# bun-bundle post-processor\n");
    fprintf(f, "export LD_PRELOAD=%s\n", shim_path);
    fprintf(f, "exec \"$(dirname \"$0\")/%s.bun\" \"$@\"\n", base);

    fclose(f);
    chmod(binary, 0755);

    printf("Bundled: %s  ->  %s (wrapper) + %s.bun (binary)\n", binary, binary, binary);
    printf("Shim:   %s\n", shim_path);
    printf("\nRun it: ./%s\n", base);

    free(bun_binary);
    free(bin_copy);
    return 0;
}
