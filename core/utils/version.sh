#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

_parse_version() {
  local output="$1"
  local ver
  ver=$(echo "$output" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
  if [ -z "$ver" ]; then
    echo ""
    return 1
  fi
  local parts
  IFS='.' read -ra parts <<< "$ver"
  if [ ${#parts[@]} -eq 2 ]; then
    echo "${parts[0]}.${parts[1]}.0"
  else
    echo "$ver"
  fi
}

_get_installed_version() {
  local binary="$1"
  local flag="${2:---version}"
  local display="${3:-$binary}"

  if ! command -v "$binary" &>/dev/null; then
    echo ""
    return 1
  fi

  _spin_capture "Detecting $display version" _detect_installed_version "$binary" "$flag"
}

_detect_installed_version() {
  local binary="$1"
  local flag="$2"
  local output
  output=$("$binary" "$flag" 2>&1)
  _parse_version "$output"
}

_spin_capture() {
  local msg="$1"
  shift
  local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local tmp
  tmp=$(mktemp)
  local spinner_fd
  if [ -c /dev/tty ] 2>/dev/null; then
    spinner_fd=/dev/tty
  else
    spinner_fd=/dev/null
  fi

  printf "    ${CYAN}%s${D_CYAN} %s${NC}" "${frames[0]}" "$msg" >"$spinner_fd"

  ("$@" >"$tmp" 2>&1) &
  local pid=$!

  local i=0
  while kill -0 "$pid" 2>/dev/null; do
    printf "\r    ${CYAN}%s${D_CYAN} %s${NC}" "${frames[i]}" "$msg" >"$spinner_fd"
    ((i = (i + 1) % ${#frames[@]}))
    sleep 0.08
  done

  wait "$pid"
  local rc=$?

  printf "\r\033[K" >"$spinner_fd"
  cat "$tmp"
  rm -f "$tmp"
  return $rc
}

_get_installed_npm_version() {
  local pkg="$1"
  local display="${2:-$pkg}"
  _spin_capture "Detecting $display version" bash -c "npm ls -g '$pkg' --depth=0 2>/dev/null | grep '$pkg@' | sed 's/.*@//'"
}

_get_remote_npm_version() {
  _spin_capture "Checking npm" npm view "$1" version 2>/dev/null
}

_get_remote_pip_version() {
  local pkg="$1"
  _spin_capture "Checking PyPI" bash -c "pip index versions '$pkg' 2>/dev/null | head -1 | awk '{print \$2}' | tr -d '()'"
}

_get_remote_github_version() {
  local repo="$1"
  local raw tag

  raw=$(_spin_capture "Checking GitHub" curl -fsSL "https://api.github.com/repos/$repo/releases/latest" 2>/dev/null)
  tag=$(echo "$raw" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

  if [ -z "$tag" ]; then
    raw=$(_spin_capture "Checking GitHub tags" curl -fsSL "https://api.github.com/repos/$repo/tags?per_page=5" 2>/dev/null)
    tag=$(echo "$raw" | grep '"name":' | head -1 | sed -E 's/.*"([^"]+)".*/\1/')
  fi

  _parse_version "$tag"
}

_get_installed_pkg_version() {
  local pkg="$1"
  local display="${2:-$pkg}"
  local raw
  raw=$(_spin_capture "Detecting $display version" apt-cache policy "$pkg" 2>/dev/null)
  echo "$raw" | grep 'Installed:' | awk '{print $2}' | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1
}

_get_installed_git_version() {
  local dir="$1"
  local display="${2:-$dir}"
  if [ ! -d "$dir/.git" ]; then
    echo ""
    return 1
  fi
  local raw
  raw=$(_spin_capture "Detecting $display version" bash -c "cd '$dir' 2>/dev/null && git fetch --tags --depth=1 2>/dev/null; cd '$dir' 2>/dev/null && git tag -l 2>/dev/null | sort -V | tail -1" 2>/dev/null)
  _parse_version "$raw"
}

_get_remote_pkg_version() {
  local raw
  raw=$(_spin_capture "Checking apt" apt-cache policy "$1" 2>/dev/null)
  echo "$raw" | grep 'Candidate:' | awk '{print $2}' | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1
}

_compare_versions() {
  local v1="$1" v2="$2"

  if [ -z "$v1" ] || [ -z "$v2" ]; then
    return 2
  fi

  if [ "$v1" = "$v2" ]; then
    return 0
  fi

  local strip_v1="${v1#v}"
  local strip_v2="${v2#v}"

  if [ "$strip_v1" = "$strip_v2" ]; then
    return 0
  fi

  return 1
}

_check_update_needed() {
  local display_name="$1"
  local installed_ver="$2"
  local remote_ver="$3"
  local update_func="$4"

  if [ -z "$installed_ver" ]; then
    log_warn "$display_name: could not detect installed version"
    echo
    local confirm_var
    read_confirm_default "Update $display_name anyway?" "y" confirm_var
    if [ "$confirm_var" = "y" ]; then
      $update_func
      return $?
    fi
    log_info "Skipped $display_name"
    return 0
  fi

  if [ -z "$remote_ver" ]; then
    log_warn "$display_name: could not detect remote version"
    echo
    local confirm_var
    read_confirm_default "Update $display_name anyway?" "y" confirm_var
    if [ "$confirm_var" = "y" ]; then
      $update_func
      return $?
    fi
    log_info "Skipped $display_name"
    return 0
  fi

  if _compare_versions "$installed_ver" "$remote_ver"; then
    log_success "$display_name is already up to date (${D_GREEN}v${installed_ver}${D_NC})"
    return 2
  fi

  echo
  log_info "$display_name: ${D_GREEN}v${installed_ver}${D_NC} → ${D_CYAN}v${remote_ver}${D_NC}"

  local confirm_var
  read_confirm_default "Update $display_name to v$remote_ver?" "y" confirm_var

  if [ "$confirm_var" = "y" ]; then
    $update_func
    return $?
  else
    log_info "Skipped $display_name"
    return 0
  fi
}
