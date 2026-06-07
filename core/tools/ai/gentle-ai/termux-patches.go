// termux-patches applies the necessary source-code changes to compile and run
// gentle-ai on Android/Termux.
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
		patchFn func(string) string
	}

	patches := []patchDef{
		{filepath.Join(srcDir, "internal/system/detect.go"), patchDetectGo},
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
		result := p.patchFn(string(content))
		if result != string(content) {
			if err := os.WriteFile(p.path, []byte(result), 0o644); err != nil {
				fmt.Fprintf(os.Stderr, "ERROR writing %s: %v\n", p.path, err)
				anyFailed = true
				continue
			}
			fmt.Printf("PATCHED %s\n", p.path)
		} else {
			fmt.Printf("UNCHANGED %s\n", p.path)
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

func replaceOne(src, old, new string) string {
	return strings.Replace(src, old, new, 1)
}

// ---------------------------------------------------------------------------
// 1. internal/system/detect.go
// ---------------------------------------------------------------------------

func patchDetectGo(src string) string {
	// 1a. IsSupportedOS: add android to the list.
	// Include the closing \n} so old1 is NOT a substring of new1 (idempotent).
	old1 := tab(1) + `return goos == "darwin" || goos == "linux" || goos == "windows"` + "\n}"
	new1 := tab(1) + `return goos == "darwin" || goos == "linux" || goos == "windows" || goos == "android"` + "\n}"
	src = replaceOne(src, old1, new1)

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
		tab(2) + `linuxOSRelease, _ := osReleaseContent(goos)` + "\n" +
		tab(2) + `distro := detectLinuxDistro(linuxOSRelease)` + "\n" +
		tab(2) + `if distro != LinuxDistroUnknown {` + "\n" +
		tab(3) + `profile.LinuxDistro = distro` + "\n" +
		tab(2) + `}` + "\n" +
		tab(2) + `return profile` + "\n" +
		tab(1) + `default:`
	src = replaceOne(src, old2, new2)

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
	src = replaceOne(src, old3, new3)

	return src
}

// ---------------------------------------------------------------------------
// 2. internal/update/upgrade/download.go
// ---------------------------------------------------------------------------

func patchDownloadGo(src string) string {
	// On Android/Termux, download linux binaries (no android releases on
	// GitHub). profile is passed by value so the modification is local.
	//
	// Match the function signature + first statement so the old pattern
	// no longer appears after replacement (idempotent).
	old1 := `func Download(ctx context.Context, r update.UpdateResult, profile system.PlatformProfile) error {` + "\n" +
		tab(1) + `if profile.OS == "windows" {`
	new1 := `func Download(ctx context.Context, r update.UpdateResult, profile system.PlatformProfile) error {` + "\n" +
		tab(1) + `if profile.OS == "android" {` + "\n" +
		tab(2) + `profile.OS = "linux"` + "\n" +
		tab(1) + `}` + "\n" +
		"\n" +
		tab(1) + `if profile.OS == "windows" {`
	src = replaceOne(src, old1, new1)
	return src
}

// ---------------------------------------------------------------------------
// 3. internal/tui/model.go
// ---------------------------------------------------------------------------

func patchModelGo(src string) string {
	// openBrowserCmd: use termux-open-url on android.
	// Include the preceding case "windows" line so old1 is NOT a
	// substring of new1 (idempotent).
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
	src = replaceOne(src, old1, new1)
	return src
}

// ---------------------------------------------------------------------------
// 4. internal/components/engram/download.go
// ---------------------------------------------------------------------------

func patchEngramDownloadGo(src string) string {
	// 4a. DownloadLatestBinary: redirect android -> linux for asset URLs.
	old1 := "" +
		tab(1) + `goos := profile.OS` + "\n" +
		tab(1) + `goarch := normalizeArch(runtime.GOARCH)`
	new1 := "" +
		tab(1) + `goos := profile.OS` + "\n" +
		tab(1) + `if goos == "android" {` + "\n" +
		tab(2) + `goos = "linux"` + "\n" +
		tab(1) + `}` + "\n" +
		tab(1) + `goarch := normalizeArch(runtime.GOARCH)`
	src = replaceOne(src, old1, new1)

	// 4b. engramInstallDir: use $PREFIX/bin on Termux.
	// Match the function signature + first statement so the old pattern
	// no longer appears after replacement (idempotent).
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
	src = replaceOne(src, old2, new2)
	return src
}
