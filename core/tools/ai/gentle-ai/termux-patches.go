// termux-patches applies the necessary source-code changes to compile and run
// gentle-ai on Android/Termux.
//
// Unlike a sed-based approach, this program uses exact Go source patterns so
// that upstream changes that break the patch are DETECTED (non-zero exit)
// rather than silently skipped.
//
// Usage:
//
//	go run termux-patches.go [source-directory]
//
// Default source-directory is "." (current directory).
// The program modifies files in-place.
package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

func main() {
	srcDir := "."
	if len(os.Args) > 1 {
		srcDir = os.Args[1]
	}

	type patchDef struct {
		path    string
		patchFn func(string) (string, error)
	}

	patches := []patchDef{
		{filepath.Join(srcDir, "internal/system/detect.go"), patchDetectGo},
		{filepath.Join(srcDir, "internal/system/guard.go"), patchGuardGo},
		{filepath.Join(srcDir, "internal/update/upgrade/download.go"), patchDownloadGo},
		{filepath.Join(srcDir, "internal/tui/model.go"), patchModelGo},
		{filepath.Join(srcDir, "internal/components/engram/download.go"), patchEngramDownloadGo},
	}

	anyFailed := false
	for _, p := range patches {
		content, err := os.ReadFile(p.path)
		if err != nil {
			fmt.Fprintf(os.Stderr, "ERROR reading %s: %v\n", p.path, err)
			anyFailed = true
			continue
		}
		result, err := p.patchFn(string(content))
		if err != nil {
			fmt.Fprintf(os.Stderr, "ERROR patching %s: %v\n", p.path, err)
			anyFailed = true
			continue
		}
		if result != string(content) {
			if err := os.WriteFile(p.path, []byte(result), 0o644); err != nil {
				fmt.Fprintf(os.Stderr, "ERROR writing %s: %v\n", p.path, err)
				anyFailed = true
				continue
			}
			fmt.Printf("PATCHED %s\n", p.path)
		} else {
			fmt.Printf("ALREADY PATCHED %s\n", p.path)
		}
	}

	if anyFailed {
		os.Exit(1)
	}
}

// ---------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------

func tab(n int) string {
	return strings.Repeat("\t", n)
}

// assertReplace replaces old with new in src once.
// If old is not found, it checks whether new is already present (idempotent).
// If neither is found, it returns an error with a descriptive message.
func assertReplace(src, old, new, desc string) (string, error) {
	if strings.Contains(src, old) {
		return strings.Replace(src, old, new, 1), nil
	}
	if strings.Contains(src, new) {
		return src, nil
	}
	return src, fmt.Errorf("%s: pattern not found in source", desc)
}

// ---------------------------------------------------------------------------
// 1. internal/system/detect.go
// ---------------------------------------------------------------------------

func patchDetectGo(src string) (string, error) {
	var err error

	// 1a. IsSupportedOS: add android to the list.
	old1 := tab(1) + `return goos == "darwin" || goos == "linux" || goos == "windows"` + "\n}"
	new1 := tab(1) + `return goos == "darwin" || goos == "linux" || goos == "windows" || goos == "android"` + "\n}"
	src, err = assertReplace(src, old1, new1, "IsSupportedOS return")
	if err != nil {
		return src, err
	}

	// 1b. resolvePlatformProfile: add case "android" before default.
	old2 := "" +
		tab(1) + `case "windows":` + "\n" +
		tab(2) + `profile.PackageManager = "winget"` + "\n" +
		tab(2) + `profile.Supported = true` + "\n" +
		tab(2) + `return profile` + "\n" +
		tab(1) + `default:`
	new2 := "" +
		tab(1) + `case "windows":` + "\n" +
		tab(2) + `profile.PackageManager = "winget"` + "\n" +
		tab(2) + `profile.Supported = true` + "\n" +
		tab(2) + `return profile` + "\n" +
		tab(1) + `case "android":` + "\n" +
		tab(2) + `profile.PackageManager = "pkg"` + "\n" +
		tab(2) + `profile.Supported = true` + "\n" +
		tab(2) + `distro := detectLinuxDistro(linuxOSRelease)` + "\n" +
		tab(2) + `if distro != LinuxDistroUnknown {` + "\n" +
		tab(3) + `profile.LinuxDistro = distro` + "\n" +
		tab(2) + `}` + "\n" +
		tab(2) + `return profile` + "\n" +
		tab(1) + `default:`
	src, err = assertReplace(src, old2, new2, "resolvePlatformProfile android case")
	if err != nil {
		return src, err
	}

	// 1c. osReleaseContent: read $PREFIX/etc/os-release on android.
	old3 := "" +
		`func osReleaseContent(goos string) (string, error) {` + "\n" +
		tab(1) + `if goos != "linux" {` + "\n" +
		tab(2) + `return "", nil` + "\n" +
		tab(1) + `}`
	new3 := "" +
		`func osReleaseContent(goos string) (string, error) {` + "\n" +
		tab(1) + `if goos == "android" {` + "\n" +
		tab(2) + `prefix := os.Getenv("PREFIX")` + "\n" +
		tab(2) + `if prefix != "" {` + "\n" +
		tab(3) + `if data, err := os.ReadFile(prefix + "/etc/os-release"); err == nil {` + "\n" +
		tab(4) + `return string(data), nil` + "\n" +
		tab(3) + `}` + "\n" +
		tab(2) + `}` + "\n" +
		tab(2) + `return "", nil` + "\n" +
		tab(1) + `}` + "\n" +
		tab(1) + `if goos != "linux" {` + "\n" +
		tab(2) + `return "", nil` + "\n" +
		tab(1) + `}`
	src, err = assertReplace(src, old3, new3, "osReleaseContent android PREFIX")
	if err != nil {
		return src, err
	}

	return src, nil
}

// ---------------------------------------------------------------------------
// 2. internal/system/guard.go
// ---------------------------------------------------------------------------

func patchGuardGo(src string) (string, error) {
	// EnsureSupportedOS error message: mention Android.
	old1 := `return fmt.Errorf("%w: only macOS, Linux, and Windows are supported (detected %s)", ErrUnsupportedOS, goos)`
	new1 := `return fmt.Errorf("%w: only macOS, Linux, Windows, and Android are supported (detected %s)", ErrUnsupportedOS, goos)`
	return assertReplace(src, old1, new1, "EnsureSupportedOS error message Android")
}

// ---------------------------------------------------------------------------
// 3. internal/update/upgrade/download.go
// ---------------------------------------------------------------------------

func patchDownloadGo(src string) (string, error) {
	// On Android/Termux, download linux binaries (no android releases on
	// GitHub). profile is passed by value so the modification is local.
	old1 := `func Download(ctx context.Context, r update.UpdateResult, profile system.PlatformProfile) error {` + "\n" +
		tab(1) + `if profile.OS == "windows" {`
	new1 := `func Download(ctx context.Context, r update.UpdateResult, profile system.PlatformProfile) error {` + "\n" +
		tab(1) + `if profile.OS == "android" {` + "\n" +
		tab(2) + `profile.OS = "linux"` + "\n" +
		tab(1) + `}` + "\n" +
		"\n" +
		tab(1) + `if profile.OS == "windows" {`
	return assertReplace(src, old1, new1, "Download android->linux redirect")
}

// ---------------------------------------------------------------------------
// 4. internal/tui/model.go
// ---------------------------------------------------------------------------

func patchModelGo(src string) (string, error) {
	// openBrowserCmd: use termux-open-url on android.
	old1 := "" +
		tab(2) + `case "windows":` + "\n" +
		tab(3) + `cmd = execCommandFn("rundll32", "url.dll,FileProtocolHandler", url)` + "\n" +
		tab(2) + `default:` + "\n" +
		tab(3) + `cmd = execCommandFn("xdg-open", url)`
	new1 := "" +
		tab(2) + `case "windows":` + "\n" +
		tab(3) + `cmd = execCommandFn("rundll32", "url.dll,FileProtocolHandler", url)` + "\n" +
		tab(2) + `case "android":` + "\n" +
		tab(3) + `cmd = execCommandFn("termux-open-url", url)` + "\n" +
		tab(2) + `default:` + "\n" +
		tab(3) + `cmd = execCommandFn("xdg-open", url)`
	return assertReplace(src, old1, new1, "openBrowserCmd android case")
}

// ---------------------------------------------------------------------------
// 5. internal/components/engram/download.go
// ---------------------------------------------------------------------------

func patchEngramDownloadGo(src string) (string, error) {
	var err error

	// 5a. DownloadLatestBinary: redirect android -> linux for asset URLs.
	old1 := "" +
		tab(1) + `goos := profile.OS` + "\n" +
		tab(1) + `goarch := normalizeArch(runtime.GOARCH)`
	new1 := "" +
		tab(1) + `goos := profile.OS` + "\n" +
		tab(1) + `if goos == "android" {` + "\n" +
		tab(2) + `goos = "linux"` + "\n" +
		tab(1) + `}` + "\n" +
		tab(1) + `goarch := normalizeArch(runtime.GOARCH)`
	src, err = assertReplace(src, old1, new1, "engram DownloadLatestBinary android->linux")
	if err != nil {
		return src, err
	}

	// 5b. engramInstallDir: use $PREFIX/bin on Termux.
	old2 := "" +
		`func engramInstallDir(goos string) string {` + "\n" +
		tab(1) + `if goos == "windows" {`
	new2 := "" +
		`func engramInstallDir(goos string) string {` + "\n" +
		tab(1) + `if goos == "android" {` + "\n" +
		tab(2) + `prefix := os.Getenv("PREFIX")` + "\n" +
		tab(2) + `if prefix != "" {` + "\n" +
		tab(3) + `return filepath.Join(prefix, "bin")` + "\n" +
		tab(2) + `}` + "\n" +
		tab(2) + `return "/data/data/com.termux/files/usr/bin"` + "\n" +
		tab(1) + `}` + "\n" +
		"\n" +
		tab(1) + `if goos == "windows" {`
	src, err = assertReplace(src, old2, new2, "engramInstallDir android PREFIX")
	if err != nil {
		return src, err
	}

	return src, nil
}
