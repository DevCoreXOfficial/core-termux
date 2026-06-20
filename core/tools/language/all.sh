#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_language.log"

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

install_all_language_packages() {
	local installed_count=0
	local failed_count=0

	for tool in "${LANGUAGE_PACKAGES[@]}"; do
		case "$tool" in
		nodejs)
			if loading "Installing Node.js LTS" install_nodejs; then ((installed_count++)); else ((failed_count++)); fi
			;;
		python)
			if loading "Installing Python" install_python; then ((installed_count++)); else ((failed_count++)); fi
			;;
		perl)
			if loading "Installing Perl" install_perl; then ((installed_count++)); else ((failed_count++)); fi
			;;
		php)
			if loading "Installing PHP" install_php; then ((installed_count++)); else ((failed_count++)); fi
			;;
		rust)
			if loading "Installing Rust" install_rust; then ((installed_count++)); else ((failed_count++)); fi
			;;
		clang)
			if loading "Installing C/C++ (clang)" install_clang; then ((installed_count++)); else ((failed_count++)); fi
			;;
		golang)
			if loading "Installing Go (golang)" install_golang; then ((installed_count++)); else ((failed_count++)); fi
			;;
		esac
	done

	return 0
}

uninstall_all_language_packages() {
	local uninstalled_count=0
	local failed_count=0

	for tool in "${LANGUAGE_PACKAGES[@]}"; do
		case "$tool" in
		nodejs)
			if loading "Uninstalling Node.js LTS" uninstall_nodejs; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		python)
			if loading "Uninstalling Python" uninstall_python; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		perl)
			if loading "Uninstalling Perl" uninstall_perl; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		php)
			if loading "Uninstalling PHP" uninstall_php; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		rust)
			if loading "Uninstalling Rust" uninstall_rust; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		clang)
			if loading "Uninstalling C/C++ (clang)" uninstall_clang; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		golang)
			if loading "Uninstalling Go (golang)" uninstall_golang; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		esac
	done

	return 0
}

update_all_language_packages() {
  local updated_count=0
  local failed_count=0

  for tool in "${LANGUAGE_PACKAGES[@]}"; do
    case "$tool" in
    nodejs)
      if loading "Updating Node.js LTS" update_nodejs; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    python)
      if loading "Updating Python" update_python; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    perl)
      if loading "Updating Perl" update_perl; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    php)
      if loading "Updating PHP" update_php; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    rust)
      if loading "Updating Rust" update_rust; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    clang)
      if loading "Updating C/C++ (clang)" update_clang; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    golang)
      if loading "Updating Go (golang)" update_golang; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    esac
  done

  return 0
}

reinstall_all_language_packages() {
  local reinstalled_count=0
  local failed_count=0

  for tool in "${LANGUAGE_PACKAGES[@]}"; do
    case "$tool" in
    nodejs)
      if loading "Reinstalling Node.js LTS" reinstall_nodejs; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    python)
      if loading "Reinstalling Python" reinstall_python; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    perl)
      if loading "Reinstalling Perl" reinstall_perl; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    php)
      if loading "Reinstalling PHP" reinstall_php; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    rust)
      if loading "Reinstalling Rust" reinstall_rust; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    clang)
      if loading "Reinstalling C/C++ (clang)" reinstall_clang; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    golang)
      if loading "Reinstalling Go (golang)" reinstall_golang; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    esac
  done

  return 0
}