#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_ai.log"
GENTLE_AI_DATA_DIR="$HOME/.local/share/core-termux-data/gentle-ai"
GITHUB_REPO_URL="https://github.com/Gentleman-Programming/gentle-ai.git"

_install_deps() {
    if ! command -v go &>/dev/null; then
        if ! pkg install golang -y &>>"$LOG_FILE"; then
            log_error "Failed to install golang"
            return 1
        fi
    fi

    if ! command -v git &>/dev/null; then
        if ! pkg install git -y &>>"$LOG_FILE"; then
            log_error "Failed to install git"
            return 1
        fi
    fi

    if ! command -v curl &>/dev/null; then
        if ! pkg install curl -y &>>"$LOG_FILE"; then
            log_error "Failed to install curl"
            return 1
        fi
    fi

    local go_version
    go_version=$(go version | sed -n 's/.*go\([0-9]*\.[0-9]*\).*/\1/p')
    local go_major="${go_version%.*}"
    local go_minor="${go_version#*.}"

    if [ "$go_major" -lt 1 ] || { [ "$go_major" -eq 1 ] && [ "$go_minor" -lt 23 ]; }; then
        log_error "Go 1.23+ required (detected $go_version). Run: pkg upgrade golang"
        return 1
    fi

    log_success "Dependencies installed (go $go_version, git, curl)"
    return 0
}

_clone_or_update_repo() {
    if [ -d "$GENTLE_AI_DATA_DIR/.git" ]; then
        log_info "Updating existing clone..."
        git -C "$GENTLE_AI_DATA_DIR" checkout -- . &>>"$LOG_FILE"
        if ! git -C "$GENTLE_AI_DATA_DIR" pull --ff-only &>>"$LOG_FILE"; then
            log_error "Failed to update gentle-ai repo"
            return 1
        fi
    else
        mkdir -p "$(dirname "$GENTLE_AI_DATA_DIR")"
        log_info "Cloning gentle-ai repo..."
        if ! git clone "$GITHUB_REPO_URL" "$GENTLE_AI_DATA_DIR" &>>"$LOG_FILE"; then
            log_error "Failed to clone gentle-ai repo"
            return 1
        fi
    fi

    log_success "Source code ready at $GENTLE_AI_DATA_DIR"
    return 0
}

_apply_patches() {
    local patcher="$CORE_PATH/tools/ai/gentle-ai/termux-patches.go"
    if [ ! -f "$patcher" ]; then
        log_warn "Termux patcher not found at $patcher, skipping"
        return 0
    fi

    log_info "Applying Termux compatibility patches..."

    if ! go run "$patcher" "$GENTLE_AI_DATA_DIR" &>>"$LOG_FILE"; then
        log_error "Failed to apply Termux patches"
        return 1
    fi

    log_success "Termux patches applied"
    return 0
}

_compile() {
    log_info "Compiling gentle-ai for Termux..."

    if ! command -v gcc &>/dev/null && ! command -v clang &>/dev/null; then
        export CGO_ENABLED=0
    fi

    local build_dir="$GENTLE_AI_DATA_DIR/cmd/gentle-ai"
    if [ ! -d "$build_dir" ]; then
        log_error "Entry point not found at cmd/gentle-ai"
        return 1
    fi

    pushd "$GENTLE_AI_DATA_DIR" &>/dev/null || return 1

    if ! go build -trimpath -ldflags="-s -w" -o gentle-ai ./cmd/gentle-ai/ &>>"$LOG_FILE"; then
        popd &>/dev/null || true
        log_error "Failed to compile gentle-ai"
        return 1
    fi

    popd &>/dev/null || true

    if [ ! -f "$GENTLE_AI_DATA_DIR/gentle-ai" ]; then
        log_error "Compilation succeeded but binary not found"
        return 1
    fi

    log_success "gentle-ai compiled successfully"
    return 0
}

_install_binary() {
    if ! cp "$GENTLE_AI_DATA_DIR/gentle-ai" "$PREFIX/bin/gentle-ai" &>>"$LOG_FILE"; then
        log_error "Failed to install binary to $PREFIX/bin/gentle-ai"
        return 1
    fi

    chmod +x "$PREFIX/bin/gentle-ai"
    log_success "Binary installed to $PREFIX/bin/gentle-ai"
    return 0
}

install_gentle_ai() {
    if command -v gentle-ai &>/dev/null; then
        log_success "gentle-ai is already installed"
        return 0
    fi

    log_info "Installing gentle-ai..."

    if ! loading "Installing dependencies" _install_deps; then
        return 1
    fi

    if ! loading "Cloning/updating source" _clone_or_update_repo; then
        return 1
    fi

    if ! loading "Applying Termux patches" _apply_patches; then
        return 1
    fi

    if ! loading "Compiling gentle-ai" _compile; then
        return 1
    fi

    if ! loading "Installing binary" _install_binary; then
        return 1
    fi

    log_success "gentle-ai installed"
    return 0
}

uninstall_gentle_ai() {
    log_info "Uninstalling gentle-ai..."
    mkdir -p "$(dirname "$LOG_FILE")"

    rm -f "$PREFIX/bin/gentle-ai"
    rm -rf "$GENTLE_AI_DATA_DIR"

    if [ ! -f "$PREFIX/bin/gentle-ai" ] && [ ! -d "$GENTLE_AI_DATA_DIR" ]; then
        log_success "gentle-ai uninstalled"
        return 0
    else
        log_error "Failed to uninstall gentle-ai"
        return 1
    fi
}

update_gentle_ai() {
    log_info "Updating gentle-ai..."
    mkdir -p "$(dirname "$LOG_FILE")"

    if ! loading "Updating source" _clone_or_update_repo; then
        return 1
    fi

    if ! loading "Applying Termux patches" _apply_patches; then
        return 1
    fi

    if ! loading "Recompiling gentle-ai" _compile; then
        return 1
    fi

    if ! loading "Reinstalling binary" _install_binary; then
        return 1
    fi

    log_success "gentle-ai updated"
    return 0
}
