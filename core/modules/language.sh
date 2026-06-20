#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_language.log"

install_language() {
	separator
	box "Installing Language Packages"
	separator
	echo

	log_info "Installing language packages..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_language_wrapper
	log_success "Language packages installed successfully"
	separator
	echo
	list_item "Node.js LTS"
	list_item "Python"
	list_item "Perl"
	list_item "PHP"
	list_item "Rust"
	list_item "C/C++ (clang)"
	list_item "Go (golang)"
	echo
}

_install_language_wrapper() {
	import "@/tools/language/all"
	install_all_language_packages
}

uninstall_language() {
	if ! command -v node &>/dev/null; then
		log_info "Language Packages are not installed"
		return 0
	fi
	separator
	box "Uninstalling Language Packages"
	separator
	echo

	log_info "Uninstalling language packages..."

	_uninstall_language_wrapper
	log_success "Language packages uninstalled"
}

_uninstall_language_wrapper() {
	import "@/tools/language/all"
	uninstall_all_language_packages
}

update_language() {
	separator
	box "Updating Language Packages"
	separator
	echo

	log_info "Updating language packages..."

	_update_language_wrapper
	log_success "Language packages updated"
}

_update_language_wrapper() {
  import "@/tools/language/all"
  update_all_language_packages
}

reinstall_language() {
  separator
  box "Reinstalling Language Packages"
  separator
  echo

  log_info "Reinstalling language packages..."

  _reinstall_language_wrapper
  log_success "Language packages reinstalled successfully"
  separator
  echo
  list_item "Node.js LTS"
  list_item "Python"
  list_item "Perl"
  list_item "PHP"
  list_item "Rust"
  list_item "C/C++ (clang)"
  list_item "Go (golang)"
  echo
}

_reinstall_language_wrapper() {
  import "@/tools/language/all"
  reinstall_all_language_packages
}