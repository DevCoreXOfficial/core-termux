#!/usr/bin/env bash

# Core - Platform detection layer.
#
# Separates the concepts of environment, operating system, distribution,
# package manager and platform id so new distributions can be added without
# touching the engine.
#
# After core_detect_platform runs, the following variables are set:
#
#   CORE_ENV        termux | linux | wsl
#   CORE_OS         android | linux
#   CORE_DISTRO     ubuntu | <other-ids>     (detection is generic)
#   CORE_PKG_MGR    pkg | apt | unknown      (dnf/pacman reserved for future)
#   CORE_PLATFORM   termux | ubuntu | wsl   (id used to resolve tool scripts)
#   CORE_SUDO       "" | "sudo"             (prefix for privileged commands)

[[ -n "${__CORE_PLATFORM_LOADED:-}" ]] && return
__CORE_PLATFORM_LOADED=1

# Officially supported today. Adding a new distribution later means:
#   1. append its id here,
#   2. map its package manager below,
#   3. provide install/<distro>.sh scripts per tool.
CORE_SUPPORTED_ENVS=(termux linux wsl)
CORE_SUPPORTED_DISTROS=(ubuntu)

# ---------------------------------------------------------------------------
# Environment detection
# ---------------------------------------------------------------------------

_is_termux() {
  [[ -n "${TERMUX_VERSION:-}" ]] || [[ "${PREFIX:-}" == */com.termux/* ]]
}

_is_wsl() {
  if grep -qi microsoft /proc/version 2>/dev/null; then
    return 0
  fi
  [[ -n "${WSL_DISTRO_NAME:-}" ]]
}

_detect_os() {
  local uname_os
  uname_os="$(uname -s 2>/dev/null || echo unknown)"
  case "$uname_os" in
    Linux) echo linux ;;
    Darwin) echo darwin ;;
    *) echo "$uname_os" ;;
  esac
}

_detect_distro() {
  local os_release=""

  if _is_termux && [[ -n "${PREFIX:-}" ]] && [[ -f "$PREFIX/etc/os-release" ]]; then
    os_release="$PREFIX/etc/os-release"
  elif [[ -f /etc/os-release ]]; then
    os_release=/etc/os-release
  fi

  if [[ -n "$os_release" ]]; then
    local id
    id="$(grep -E '^ID=' "$os_release" 2>/dev/null | cut -d= -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]')"
    case "$id" in
      ubuntu) echo ubuntu ;;
      debian) echo debian ;;
      fedora) echo fedora ;;
      arch|manjaro) echo arch ;;
      *) echo "$id" ;;
    esac
    return
  fi

  echo unknown
}

_detect_pkg_manager() {
  case "$CORE_DISTRO" in
    ubuntu)
      if command -v apt-get &>/dev/null; then echo apt; else echo unknown; fi
      ;;
    # Reserved for future distributions — detection stays generic.
    debian|fedora|arch)
      if command -v apt-get &>/dev/null; then echo apt
      elif command -v dnf &>/dev/null; then echo dnf
      elif command -v pacman &>/dev/null; then echo pacman
      else echo unknown; fi
      ;;
    *)
      if _is_termux && command -v pkg &>/dev/null; then
        echo pkg
      else
        echo unknown
      fi
      ;;
  esac
}

_detect_sudo() {
  # Termux never uses sudo; on WSL/Linux prefer passwordless flow when root.
  if _is_termux; then
    echo ""
    return
  fi
  if [[ "$(id -u)" -eq 0 ]]; then
    echo ""
  elif command -v sudo &>/dev/null; then
    echo "sudo"
  else
    echo ""
  fi
}

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

core_detect_platform() {
  if _is_termux; then
    CORE_ENV=termux
    CORE_OS=android
  elif _is_wsl; then
    CORE_ENV=wsl
    CORE_OS=linux
  else
    CORE_ENV=linux
    CORE_OS=linux
  fi

  CORE_DISTRO="$(_detect_distro)"
  CORE_PKG_MGR="$(_detect_pkg_manager)"
  CORE_SUDO="$(_detect_sudo)"

  # Platform id: termux keeps its own identity; linux resolves to the distro;
  # wsl is its own platform (distro-aware fallback handled by script resolver).
  case "$CORE_ENV" in
    termux) CORE_PLATFORM=termux ;;
    wsl) CORE_PLATFORM=wsl ;;
    linux) CORE_PLATFORM="$CORE_DISTRO" ;;
  esac

  export CORE_ENV CORE_OS CORE_DISTRO CORE_PKG_MGR CORE_PLATFORM CORE_SUDO
}

# Returns 0 when the current environment is in the supported list.
core_env_supported() {
  local env
  for env in "${CORE_SUPPORTED_ENVS[@]}"; do
    [[ "$env" == "$CORE_ENV" ]] && return 0
  done
  return 1
}

# Returns 0 when the current distribution is officially supported.
core_distro_supported() {
  local distro
  for distro in "${CORE_SUPPORTED_DISTROS[@]}"; do
    [[ "$distro" == "$CORE_DISTRO" ]] && return 0
  done
  return 1
}

# Returns 0 when the full environment (env + distro) is supported.
# Termux is always allowed; Linux/WSL currently require Ubuntu.
core_platform_supported() {
  core_env_supported || return 1
  [[ "$CORE_ENV" == "termux" ]] && return 0
  core_distro_supported
}

# Human readable description of the current environment.
core_platform_label() {
  case "$CORE_PLATFORM" in
    termux) echo "Termux / Android" ;;
    wsl) echo "Ubuntu (WSL)" ;;
    ubuntu) echo "Ubuntu Linux" ;;
    debian) echo "Debian Linux" ;;
    fedora) echo "Fedora Linux" ;;
    arch) echo "Arch Linux" ;;
    *) echo "$CORE_OS ($CORE_PLATFORM)" ;;
  esac
}

# Package manager install helper: pm_install <package> [<package>...]
pm_install() {
  case "$CORE_PKG_MGR" in
    pkg)
      yes | pkg install -y "$@" &>>"${LOG_FILE:-/dev/null}"
      ;;
    apt)
      $CORE_SUDO apt-get update -qq &>>"${LOG_FILE:-/dev/null}"
      $CORE_SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y "$@" &>>"${LOG_FILE:-/dev/null}"
      ;;
    dnf)
      $CORE_SUDO dnf install -y "$@" &>>"${LOG_FILE:-/dev/null}"
      ;;
    pacman)
      $CORE_SUDO pacman -S --noconfirm "$@" &>>"${LOG_FILE:-/dev/null}"
      ;;
    *)
      return 1
      ;;
  esac
}

# Package manager uninstall helper: pm_remove <package> [<package>...]
pm_remove() {
  case "$CORE_PKG_MGR" in
    pkg)
      yes | pkg uninstall -y "$@" &>>"${LOG_FILE:-/dev/null}"
      ;;
    apt)
      $CORE_SUDO DEBIAN_FRONTEND=noninteractive apt-get purge -y "$@" &>>"${LOG_FILE:-/dev/null}"
      $CORE_SUDO DEBIAN_FRONTEND=noninteractive apt-get autoremove -y &>>"${LOG_FILE:-/dev/null}"
      ;;
    dnf)
      $CORE_SUDO dnf remove -y "$@" &>>"${LOG_FILE:-/dev/null}"
      ;;
    pacman)
      $CORE_SUDO pacman -Rns --noconfirm "$@" &>>"${LOG_FILE:-/dev/null}"
      ;;
    *)
      return 1
      ;;
  esac
}

# True when the given platform id matches the current one (wsl accepts ubuntu).
platform_matches() {
  local want="$1"
  [[ "$want" == "$CORE_PLATFORM" ]] && return 0
  [[ "$want" == "linux" && "$CORE_OS" == "linux" ]] && return 0
  [[ "$want" == "ubuntu" && "$CORE_PLATFORM" == "wsl" ]] && return 0
  return 1
}
