#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_lang.log"

LANGUAGE_PACKAGES=(
	"nodejs"
	"python"
	"perl"
	"php"
	"rust"
	"clang"
	"golang"
)

source "$(dirname "$BASH_SOURCE")/nodejs/install.sh"
source "$(dirname "$BASH_SOURCE")/python/install.sh"
source "$(dirname "$BASH_SOURCE")/perl/install.sh"
source "$(dirname "$BASH_SOURCE")/php/install.sh"
source "$(dirname "$BASH_SOURCE")/rust/install.sh"
source "$(dirname "$BASH_SOURCE")/clang/install.sh"
source "$(dirname "$BASH_SOURCE")/golang/install.sh"

install_all_lang_packages() {
	local installed_count=0
	local failed_count=0

	for tool in "${LANGUAGE_PACKAGES[@]}"; do
		case "$tool" in
		nodejs)
			loading "Installing Node.js LTS" install_npmjs
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		python)
			loading "Installing Python" install_python
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		perl)
			loading "Installing Perl" install_perl
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		php)
			loading "Installing PHP" install_php
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		rust)
			loading "Installing Rust" install_rust
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		clang)
			loading "Installing C/C++ (clang)" install_clang
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		golang)
			loading "Installing Go (golang)" install_golang
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		esac
	done

	return 0
}

uninstall_all_lang_packages() {
	local uninstalled_count=0
	local failed_count=0

	for tool in "${LANGUAGE_PACKAGES[@]}"; do
		case "$tool" in
		nodejs)
			loading "Uninstalling Node.js LTS" uninstall_npmjs
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		python)
			loading "Uninstalling Python" uninstall_python
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		perl)
			loading "Uninstalling Perl" uninstall_perl
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		php)
			loading "Uninstalling PHP" uninstall_php
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		rust)
			loading "Uninstalling Rust" uninstall_rust
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		clang)
			loading "Uninstalling C/C++ (clang)" uninstall_clang
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		golang)
			loading "Uninstalling Go (golang)" uninstall_golang
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		esac
	done

	return 0
}

update_all_lang_packages() {
  local updated_count=0
  local failed_count=0

  for tool in "${LANGUAGE_PACKAGES[@]}"; do
    case "$tool" in
    nodejs)
      loading "Updating Node.js LTS" update_npmjs
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    python)
      loading "Updating Python" update_python
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    perl)
      loading "Updating Perl" update_perl
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    php)
      loading "Updating PHP" update_php
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    rust)
      loading "Updating Rust" update_rust
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    clang)
      loading "Updating C/C++ (clang)" update_clang
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    golang)
      loading "Updating Go (golang)" update_golang
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    esac
  done

  return 0
}

reinstall_all_lang_packages() {
  local reinstalled_count=0
  local failed_count=0

  for tool in "${LANGUAGE_PACKAGES[@]}"; do
    case "$tool" in
    nodejs)
      loading "Reinstalling Node.js LTS" reinstall_npmjs
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    python)
      loading "Reinstalling Python" reinstall_python
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    perl)
      loading "Reinstalling Perl" reinstall_perl
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    php)
      loading "Reinstalling PHP" reinstall_php
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    rust)
      loading "Reinstalling Rust" reinstall_rust
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    clang)
      loading "Reinstalling C/C++ (clang)" reinstall_clang
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    golang)
      loading "Reinstalling Go (golang)" reinstall_golang
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    esac
  done

  return 0
}