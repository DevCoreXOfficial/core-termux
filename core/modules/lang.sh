#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_lang.log"

install_lang() {
	separator
	box "Installing Language Packages"
	separator
	echo

	log_info "Installing language packages..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_lang_wrapper
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

_install_lang_wrapper() {
	import "@/tools/lang/all"
	install_all_lang_packages
}

uninstall_lang() {
	if ! command -v node &>/dev/null; then
		log_info "Language Packages are not installed"
		return 0
	fi
	separator
	box "Uninstalling Language Packages"
	separator
	echo

	log_info "Uninstalling language packages..."

	_uninstall_lang_wrapper
	log_success "Language packages uninstalled"
}

_uninstall_lang_wrapper() {
	import "@/tools/lang/all"
	uninstall_all_lang_packages
}

update_lang() {
	separator
	box "Updating Language Packages"
	separator
	echo

	log_info "Updating language packages..."

	_update_lang_wrapper
	log_success "Language packages updated"
}

_update_lang_wrapper() {
  import "@/tools/lang/all"
  update_all_lang_packages
}

reinstall_lang() {
  separator
  box "Reinstalling Language Packages"
  separator
  echo

  log_info "Reinstalling language packages..."

  _reinstall_lang_wrapper
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

_reinstall_lang_wrapper() {
  import "@/tools/lang/all"
  reinstall_all_lang_packages
}