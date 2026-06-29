#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

: "${CORE_CACHE:=$HOME/.cache/core-termux}"
: "${CORE_PATH:=$HOME/core-termux/core}"
: "${PREFIX:=/data/data/com.termux/files/usr}"

LOG_FILE="$CORE_CACHE/install_ai.log"
GENTLE_AI_DATA_DIR="${GENTLE_AI_DATA_DIR:-$HOME/.local/share/core-termux-data/gentle-ai}"

_gentle_ai_dependencies() {
  loading "Installing dependencies" _gentle_ai_dependencies_impl
}

_gentle_ai_dependencies_impl() {
  declare -A DEPS=(
    ["golang"]="go"
    ["git"]="git"
    ["curl"]="curl"
  )

  local pkg_name bin_name
  for pkg_name in "${!DEPS[@]}"; do
    bin_name="${DEPS[$pkg_name]}"
    if ! command -v "$bin_name" &>/dev/null; then
      if ! yes | pkg install "$pkg_name" &>>"$LOG_FILE"; then
        log_error "Failed to install $pkg_name"
        return 1
      fi
    fi
  done

  return 0
}

_gentle_ai_ensure_go() {
  loading "Checking Go version" _gentle_ai_ensure_go_impl
}

_gentle_ai_ensure_go_impl() {
  if ! command -v go &>/dev/null; then
    log_error "Go is required but not installed"
    return 1
  fi

  local go_installed
  go_installed=$(go version | sed 's/.*go\([0-9.]*\).*/\1/')

  local go_required
  if [ -f "$GENTLE_AI_DATA_DIR/go.mod" ]; then
    go_required=$(sed -n 's/^go \([0-9.]*\)/\1/p' "$GENTLE_AI_DATA_DIR/go.mod" | head -1)
  fi

  if [ -z "$go_required" ]; then
    go_required="1.25.0"
  fi

  if ! _version_ge "$go_installed" "$go_required"; then
    log_error "Go $go_required+ required (detected $go_installed). Run: pkg upgrade golang"
    return 1
  fi

  return 0
}

_version_ge() {
  local v1="$1" v2="$2"
  local highest
  highest=$(printf '%s\n%s\n' "$v1" "$v2" | sort -V | tail -1)
  [ "$highest" = "$v1" ]
}

_clone_or_update_repo() {
  loading "Cloning or updating gentle-ai repo" _clone_or_update_repo_impl
}

_clone_or_update_repo_impl() {
  local repo_url="https://github.com/Gentleman-Programming/gentle-ai.git"

  if [ -d "$GENTLE_AI_DATA_DIR/.git" ]; then
    git -C "$GENTLE_AI_DATA_DIR" remote set-url origin "$repo_url" &>>"$LOG_FILE"
    git -C "$GENTLE_AI_DATA_DIR" stash --include-untracked &>>"$LOG_FILE" || true
    if ! git -C "$GENTLE_AI_DATA_DIR" fetch origin &>>"$LOG_FILE"; then
      log_error "Failed to fetch from remote"
      return 1
    fi
    if ! git -C "$GENTLE_AI_DATA_DIR" reset --hard origin/main &>>"$LOG_FILE"; then
      log_error "Failed to reset to origin/main"
      return 1
    fi
  else
    if [ -d "$GENTLE_AI_DATA_DIR" ]; then
      rm -rf "$GENTLE_AI_DATA_DIR"
    fi
    if ! git clone "$repo_url" "$GENTLE_AI_DATA_DIR" &>>"$LOG_FILE"; then
      log_error "Failed to clone gentle-ai repo"
      return 1
    fi
  fi

  return 0
}

_build_and_apply_patches() {
  loading "Applying Termux patches" _build_and_apply_patches_impl
}

_build_and_apply_patches_impl() {
  local patcher_src="$CORE_PATH/tools/ai/gentle-ai/termux-patches.go"
  local patcher_bin="$CORE_CACHE/termux-patcher"

  mkdir -p "$CORE_CACHE"

  if [ ! -f "$patcher_bin" ] || [ "$patcher_src" -nt "$patcher_bin" ]; then
    if ! go build -o "$patcher_bin" "$patcher_src" &>>"$LOG_FILE"; then
      log_error "Failed to compile patcher"
      return 1
    fi
  fi

  pushd "$GENTLE_AI_DATA_DIR" &>/dev/null || return 1

  local patch_out patch_rc
  patch_out=$("$patcher_bin" "$GENTLE_AI_DATA_DIR" 2>&1)
  patch_rc=$?

  echo "$patch_out" >>"$LOG_FILE"

  if [ $patch_rc -ne 0 ]; then
    popd &>/dev/null || true
    echo ""
    log_error "Termux patches failed. Output:"
    echo "$patch_out"
    return 1
  fi

  popd &>/dev/null || true
  return 0
}

_compile() {
  loading "Compiling gentle-ai" _compile_impl
}

_compile_impl() {
  if ! command -v gcc &>/dev/null && ! command -v clang &>/dev/null; then
    export CGO_ENABLED=0
  fi

  local build_dir="$GENTLE_AI_DATA_DIR/cmd/gentle-ai"
  if [ ! -d "$build_dir" ]; then
    log_error "Entry point not found at cmd/gentle-ai"
    return 1
  fi

  pushd "$GENTLE_AI_DATA_DIR" &>/dev/null || return 1

  if ! go mod download &>>"$LOG_FILE"; then
    popd &>/dev/null || true
    log_error "Failed to download Go dependencies"
    return 1
  fi

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

  return 0
}

_install_binary() {
  loading "Installing binary" _install_binary_impl
}

_install_binary_impl() {
  if ! cp "$GENTLE_AI_DATA_DIR/gentle-ai" "$PREFIX/bin/gentle-ai" &>>"$LOG_FILE"; then
    log_error "Failed to install binary to $PREFIX/bin/gentle-ai"
    return 1
  fi

  chmod +x "$PREFIX/bin/gentle-ai"
  return 0
}

install_gentle_ai() {
  if command -v gentle-ai &>/dev/null; then
    log_info "gentle-ai is already installed"
    return 2
  fi

  log_info "Installing gentle-ai..."
  mkdir -p "$(dirname "$LOG_FILE")" "$CORE_CACHE"

  _gentle_ai_dependencies || return 1
  _clone_or_update_repo || return 1
  _gentle_ai_ensure_go || return 1
  _build_and_apply_patches || return 1
  _compile || return 1
  _install_binary || return 1

  log_success "gentle-ai installed"
  return 0
}

uninstall_gentle_ai() {
  if ! command -v gentle-ai &>/dev/null; then
    log_info "gentle-ai is not installed"
    return 2
  fi
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

  _clone_or_update_repo || return 1
  _gentle_ai_ensure_go || return 1
  _build_and_apply_patches || return 1
  _compile || return 1
  _install_binary || return 1

  log_success "gentle-ai updated"
  return 0
}

reinstall_gentle_ai() {
  uninstall_gentle_ai
  install_gentle_ai
}
