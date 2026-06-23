#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_dev.log"

install_dev() {
	separator
	box "Installing Development Tools"
	separator
	echo

	log_info "Installing development tools..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_dev_wrapper
	log_success "Tools installed successfully"
	separator
	echo
	list_item "GitHub CLI"
	list_item "Wget"
	list_item "Curl"
	list_item "LSD (ls replacement)"
	list_item "Bat (cat replacement)"
	list_item "Proot (chroot alternative)"
	list_item "Ncurses Utils"
	list_item "Tmate (terminal sharing)"
	list_item "Cloudflared (Cloudflare Tunnel)"
	list_item "Translate Shell"
	list_item "html2text (HTML to text converter)"
	list_item "jq (JSON processor)"
	list_item "bc (calculator)"
	list_item "Tree (directory listing)"
	list_item "Fzf (fuzzy finder)"
	list_item "ImageMagick (image manipulation)"
	list_item "Shfmt (shell script formatter)"
	list_item "Make (build automation)"
	list_item "Udocker (container management)"
	echo
}

_install_dev_wrapper() {
	import "@/tools/dev/all"
	install_all_dev
}

uninstall_dev() {
	if ! command -v gh &>/dev/null; then
		log_info "Development Tools are not installed"
		return 0
	fi
	separator
	box "Uninstalling Development Tools"
	separator
	echo

	log_info "Uninstalling development tools..."

	_uninstall_dev_wrapper
	log_success "Tools uninstalled"
}

_uninstall_dev_wrapper() {
	import "@/tools/dev/all"
	uninstall_all_dev
}

update_dev() {
	separator
	box "Updating Development Tools"
	separator
	echo

	log_info "Updating development tools..."

	_update_dev_wrapper
	log_success "Tools updated"
}

_update_dev_wrapper() {
  import "@/tools/dev/all"
  update_all_dev
}

reinstall_dev() {
  separator
  box "Reinstalling Development Tools"
  separator
  echo

  log_info "Reinstalling development tools..."

  _reinstall_dev_wrapper
  log_success "Tools reinstalled successfully"
  separator
  echo
  list_item "GitHub CLI"
  list_item "Wget"
  list_item "Curl"
  list_item "LSD (ls replacement)"
  list_item "Bat (cat replacement)"
  list_item "Proot (chroot alternative)"
  list_item "Ncurses Utils"
  list_item "Tmate (terminal sharing)"
  list_item "Cloudflared (Cloudflare Tunnel)"
  list_item "Translate Shell"
  list_item "html2text (HTML to text converter)"
  list_item "jq (JSON processor)"
  list_item "bc (calculator)"
  list_item "Tree (directory listing)"
  list_item "Fzf (fuzzy finder)"
  list_item "ImageMagick (image manipulation)"
  list_item "Shfmt (shell script formatter)"
  list_item "Make (build automation)"
  list_item "Udocker (container management)"
  echo
}

_reinstall_dev_wrapper() {
  import "@/tools/dev/all"
  reinstall_all_dev
}