#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_dev.log"

TOOLS_PACKAGES=(
	"gh"
	"wget"
	"curl"
	"lsd"
	"bat"
	"proot"
	"ncurses"
	"tmate"
	"cloudflared"
	"translate"
	"html2text"
	"jq"
	"bc"
	"tree"
	"fzf"
	"imagemagick"
	"shfmt"
	"make"
	"udocker"
)

source "$(dirname "$BASH_SOURCE")/gh/install.sh"
source "$(dirname "$BASH_SOURCE")/wget/install.sh"
source "$(dirname "$BASH_SOURCE")/curl/install.sh"
source "$(dirname "$BASH_SOURCE")/lsd/install.sh"
source "$(dirname "$BASH_SOURCE")/bat/install.sh"
source "$(dirname "$BASH_SOURCE")/proot/install.sh"
source "$(dirname "$BASH_SOURCE")/ncurses/install.sh"
source "$(dirname "$BASH_SOURCE")/tmate/install.sh"
source "$(dirname "$BASH_SOURCE")/cloudflared/install.sh"
source "$(dirname "$BASH_SOURCE")/translate/install.sh"
source "$(dirname "$BASH_SOURCE")/html2text/install.sh"
source "$(dirname "$BASH_SOURCE")/jq/install.sh"
source "$(dirname "$BASH_SOURCE")/bc/install.sh"
source "$(dirname "$BASH_SOURCE")/tree/install.sh"
source "$(dirname "$BASH_SOURCE")/fzf/install.sh"
source "$(dirname "$BASH_SOURCE")/imagemagick/install.sh"
source "$(dirname "$BASH_SOURCE")/shfmt/install.sh"
source "$(dirname "$BASH_SOURCE")/make/install.sh"
source "$(dirname "$BASH_SOURCE")/udocker/install.sh"

install_all_dev() {
	local installed_count=0
	local failed_count=0

	for tool in "${TOOLS_PACKAGES[@]}"; do
		case "$tool" in
		gh)
			loading "Installing GitHub CLI" install_gh
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		wget)
			loading "Installing Wget" install_wget
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		curl)
			loading "Installing Curl" install_curl
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		lsd)
			loading "Installing LSD" install_lsd
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		bat)
			loading "Installing Bat" install_bat
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		proot)
			loading "Installing Proot" install_proot
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		ncurses)
			loading "Installing Ncurses Utils" install_ncurses
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		tmate)
			loading "Installing Tmate" install_tmate
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		cloudflared)
			loading "Installing Cloudflared" install_cloudflared
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		translate)
			loading "Installing Translate Shell" install_translate
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		html2text)
			loading "Installing html2text" install_html2text
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		jq)
			loading "Installing jq" install_jq
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		bc)
			loading "Installing bc" install_bc
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		tree)
			loading "Installing Tree" install_tree
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		fzf)
			loading "Installing Fzf" install_fzf
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		imagemagick)
			loading "Installing ImageMagick" install_imagemagick
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		shfmt)
			loading "Installing Shfmt" install_shfmt
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		make)
			loading "Installing Make" install_make
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		udocker)
			loading "Installing Udocker" install_udocker
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		esac
	done

	return 0
}

uninstall_all_dev() {
	local uninstalled_count=0
	local failed_count=0

	for tool in "${TOOLS_PACKAGES[@]}"; do
		case "$tool" in
		gh)
			loading "Uninstalling GitHub CLI" uninstall_gh
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		wget)
			loading "Uninstalling Wget" uninstall_wget
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		curl)
			loading "Uninstalling Curl" uninstall_curl
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		lsd)
			loading "Uninstalling LSD" uninstall_lsd
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		bat)
			loading "Uninstalling Bat" uninstall_bat
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		proot)
			loading "Uninstalling Proot" uninstall_proot
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		ncurses)
			loading "Uninstalling Ncurses Utils" uninstall_ncurses
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		tmate)
			loading "Uninstalling Tmate" uninstall_tmate
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		cloudflared)
			loading "Uninstalling Cloudflared" uninstall_cloudflared
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		translate)
			loading "Uninstalling Translate Shell" uninstall_translate
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		html2text)
			loading "Uninstalling html2text" uninstall_html2text
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		jq)
			loading "Uninstalling jq" uninstall_jq
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		bc)
			loading "Uninstalling bc" uninstall_bc
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		tree)
			loading "Uninstalling Tree" uninstall_tree
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		fzf)
			loading "Uninstalling Fzf" uninstall_fzf
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		imagemagick)
			loading "Uninstalling ImageMagick" uninstall_imagemagick
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		shfmt)
			loading "Uninstalling Shfmt" uninstall_shfmt
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		make)
			loading "Uninstalling Make" uninstall_make
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		udocker)
			loading "Uninstalling Udocker" uninstall_udocker
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		esac
	done

	return 0
}

update_all_dev() {
  local updated_count=0
  local failed_count=0

  for tool in "${TOOLS_PACKAGES[@]}"; do
    case "$tool" in
    gh)
      loading "Updating GitHub CLI" update_gh
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    wget)
      loading "Updating Wget" update_wget
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    curl)
      loading "Updating Curl" update_curl
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    lsd)
      loading "Updating LSD" update_lsd
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    bat)
      loading "Updating Bat" update_bat
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    proot)
      loading "Updating Proot" update_proot
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    ncurses)
      loading "Updating Ncurses Utils" update_ncurses
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    tmate)
      loading "Updating Tmate" update_tmate
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    cloudflared)
      loading "Updating Cloudflared" update_cloudflared
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    translate)
      loading "Updating Translate Shell" update_translate
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    html2text)
      loading "Updating html2text" update_html2text
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    jq)
      loading "Updating jq" update_jq
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    bc)
      loading "Updating bc" update_bc
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    tree)
      loading "Updating Tree" update_tree
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    fzf)
      loading "Updating Fzf" update_fzf
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    imagemagick)
      loading "Updating ImageMagick" update_imagemagick
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    shfmt)
      loading "Updating Shfmt" update_shfmt
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    make)
      loading "Updating Make" update_make
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    udocker)
      loading "Updating Udocker" update_udocker
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    esac
  done

  return 0
}

reinstall_all_dev() {
  local reinstalled_count=0
  local failed_count=0

  for tool in "${TOOLS_PACKAGES[@]}"; do
    case "$tool" in
    gh)
      loading "Reinstalling GitHub CLI" reinstall_gh
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    wget)
      loading "Reinstalling Wget" reinstall_wget
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    curl)
      loading "Reinstalling Curl" reinstall_curl
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    lsd)
      loading "Reinstalling LSD" reinstall_lsd
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    bat)
      loading "Reinstalling Bat" reinstall_bat
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    proot)
      loading "Reinstalling Proot" reinstall_proot
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    ncurses)
      loading "Reinstalling Ncurses Utils" reinstall_ncurses
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    tmate)
      loading "Reinstalling Tmate" reinstall_tmate
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    cloudflared)
      loading "Reinstalling Cloudflared" reinstall_cloudflared
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    translate)
      loading "Reinstalling Translate Shell" reinstall_translate
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    html2text)
      loading "Reinstalling html2text" reinstall_html2text
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    jq)
      loading "Reinstalling jq" reinstall_jq
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    bc)
      loading "Reinstalling bc" reinstall_bc
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    tree)
      loading "Reinstalling Tree" reinstall_tree
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    fzf)
      loading "Reinstalling Fzf" reinstall_fzf
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    imagemagick)
      loading "Reinstalling ImageMagick" reinstall_imagemagick
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    shfmt)
      loading "Reinstalling Shfmt" reinstall_shfmt
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    make)
      loading "Reinstalling Make" reinstall_make
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    udocker)
      loading "Reinstalling Udocker" reinstall_udocker
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    esac
  done

  return 0
}