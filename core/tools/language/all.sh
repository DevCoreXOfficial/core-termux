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
			if install_nodejs; then ((installed_count++)); else ((failed_count++)); fi
			;;
		python)
			if install_python; then ((installed_count++)); else ((failed_count++)); fi
			;;
		perl)
			if install_perl; then ((installed_count++)); else ((failed_count++)); fi
			;;
		php)
			if install_php; then ((installed_count++)); else ((failed_count++)); fi
			;;
		rust)
			if install_rust; then ((installed_count++)); else ((failed_count++)); fi
			;;
		clang)
			if install_clang; then ((installed_count++)); else ((failed_count++)); fi
			;;
		golang)
			if install_golang; then ((installed_count++)); else ((failed_count++)); fi
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
			if uninstall_nodejs; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		python)
			if uninstall_python; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		perl)
			if uninstall_perl; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		php)
			if uninstall_php; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		rust)
			if uninstall_rust; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		clang)
			if uninstall_clang; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		golang)
			if uninstall_golang; then ((uninstalled_count++)); else ((failed_count++)); fi
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
      if update_nodejs; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    python)
      if update_python; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    perl)
      if update_perl; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    php)
      if update_php; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    rust)
      if update_rust; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    clang)
      if update_clang; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    golang)
      if update_golang; then ((updated_count++)); else ((failed_count++)); fi
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
      if reinstall_nodejs; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    python)
      if reinstall_python; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    perl)
      if reinstall_perl; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    php)
      if reinstall_php; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    rust)
      if reinstall_rust; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    clang)
      if reinstall_clang; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    golang)
      if reinstall_golang; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    esac
  done

  return 0
}