#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_tools.log"

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

install_all_tools() {
	local installed_count=0
	local failed_count=0

	for tool in "${TOOLS_PACKAGES[@]}"; do
		case "$tool" in
		gh)
			if loading "Installing GitHub CLI" install_gh; then ((installed_count++)); else ((failed_count++)); fi
			;;
		wget)
			if loading "Installing Wget" install_wget; then ((installed_count++)); else ((failed_count++)); fi
			;;
		curl)
			if loading "Installing Curl" install_curl; then ((installed_count++)); else ((failed_count++)); fi
			;;
		lsd)
			if loading "Installing LSD" install_lsd; then ((installed_count++)); else ((failed_count++)); fi
			;;
		bat)
			if loading "Installing Bat" install_bat; then ((installed_count++)); else ((failed_count++)); fi
			;;
		proot)
			if loading "Installing Proot" install_proot; then ((installed_count++)); else ((failed_count++)); fi
			;;
		ncurses)
			if loading "Installing Ncurses Utils" install_ncurses; then ((installed_count++)); else ((failed_count++)); fi
			;;
		tmate)
			if loading "Installing Tmate" install_tmate; then ((installed_count++)); else ((failed_count++)); fi
			;;
		cloudflared)
			if loading "Installing Cloudflared" install_cloudflared; then ((installed_count++)); else ((failed_count++)); fi
			;;
		translate)
			if loading "Installing Translate Shell" install_translate; then ((installed_count++)); else ((failed_count++)); fi
			;;
		html2text)
			if loading "Installing html2text" install_html2text; then ((installed_count++)); else ((failed_count++)); fi
			;;
		jq)
			if loading "Installing jq" install_jq; then ((installed_count++)); else ((failed_count++)); fi
			;;
		bc)
			if loading "Installing bc" install_bc; then ((installed_count++)); else ((failed_count++)); fi
			;;
		tree)
			if loading "Installing Tree" install_tree; then ((installed_count++)); else ((failed_count++)); fi
			;;
		fzf)
			if loading "Installing Fzf" install_fzf; then ((installed_count++)); else ((failed_count++)); fi
			;;
		imagemagick)
			if loading "Installing ImageMagick" install_imagemagick; then ((installed_count++)); else ((failed_count++)); fi
			;;
		shfmt)
			if loading "Installing Shfmt" install_shfmt; then ((installed_count++)); else ((failed_count++)); fi
			;;
		make)
			if loading "Installing Make" install_make; then ((installed_count++)); else ((failed_count++)); fi
			;;
		udocker)
			if loading "Installing Udocker" install_udocker; then ((installed_count++)); else ((failed_count++)); fi
			;;
		esac
	done

	return 0
}

uninstall_all_tools() {
	local uninstalled_count=0
	local failed_count=0

	for tool in "${TOOLS_PACKAGES[@]}"; do
		case "$tool" in
		gh)
			if loading "Uninstalling GitHub CLI" uninstall_gh; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		wget)
			if loading "Uninstalling Wget" uninstall_wget; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		curl)
			if loading "Uninstalling Curl" uninstall_curl; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		lsd)
			if loading "Uninstalling LSD" uninstall_lsd; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		bat)
			if loading "Uninstalling Bat" uninstall_bat; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		proot)
			if loading "Uninstalling Proot" uninstall_proot; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		ncurses)
			if loading "Uninstalling Ncurses Utils" uninstall_ncurses; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		tmate)
			if loading "Uninstalling Tmate" uninstall_tmate; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		cloudflared)
			if loading "Uninstalling Cloudflared" uninstall_cloudflared; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		translate)
			if loading "Uninstalling Translate Shell" uninstall_translate; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		html2text)
			if loading "Uninstalling html2text" uninstall_html2text; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		jq)
			if loading "Uninstalling jq" uninstall_jq; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		bc)
			if loading "Uninstalling bc" uninstall_bc; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		tree)
			if loading "Uninstalling Tree" uninstall_tree; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		fzf)
			if loading "Uninstalling Fzf" uninstall_fzf; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		imagemagick)
			if loading "Uninstalling ImageMagick" uninstall_imagemagick; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		shfmt)
			if loading "Uninstalling Shfmt" uninstall_shfmt; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		make)
			if loading "Uninstalling Make" uninstall_make; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		udocker)
			if loading "Uninstalling Udocker" uninstall_udocker; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		esac
	done

	return 0
}

update_all_tools() {
  local updated_count=0
  local failed_count=0

  for tool in "${TOOLS_PACKAGES[@]}"; do
    case "$tool" in
    gh)
      if loading "Updating GitHub CLI" update_gh; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    wget)
      if loading "Updating Wget" update_wget; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    curl)
      if loading "Updating Curl" update_curl; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    lsd)
      if loading "Updating LSD" update_lsd; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    bat)
      if loading "Updating Bat" update_bat; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    proot)
      if loading "Updating Proot" update_proot; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    ncurses)
      if loading "Updating Ncurses Utils" update_ncurses; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    tmate)
      if loading "Updating Tmate" update_tmate; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    cloudflared)
      if loading "Updating Cloudflared" update_cloudflared; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    translate)
      if loading "Updating Translate Shell" update_translate; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    html2text)
      if loading "Updating html2text" update_html2text; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    jq)
      if loading "Updating jq" update_jq; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    bc)
      if loading "Updating bc" update_bc; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    tree)
      if loading "Updating Tree" update_tree; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    fzf)
      if loading "Updating Fzf" update_fzf; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    imagemagick)
      if loading "Updating ImageMagick" update_imagemagick; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    shfmt)
      if loading "Updating Shfmt" update_shfmt; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    make)
      if loading "Updating Make" update_make; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    udocker)
      if loading "Updating Udocker" update_udocker; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    esac
  done

  return 0
}

reinstall_all_tools() {
  local reinstalled_count=0
  local failed_count=0

  for tool in "${TOOLS_PACKAGES[@]}"; do
    case "$tool" in
    gh)
      if loading "Reinstalling GitHub CLI" reinstall_gh; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    wget)
      if loading "Reinstalling Wget" reinstall_wget; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    curl)
      if loading "Reinstalling Curl" reinstall_curl; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    lsd)
      if loading "Reinstalling LSD" reinstall_lsd; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    bat)
      if loading "Reinstalling Bat" reinstall_bat; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    proot)
      if loading "Reinstalling Proot" reinstall_proot; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    ncurses)
      if loading "Reinstalling Ncurses Utils" reinstall_ncurses; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    tmate)
      if loading "Reinstalling Tmate" reinstall_tmate; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    cloudflared)
      if loading "Reinstalling Cloudflared" reinstall_cloudflared; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    translate)
      if loading "Reinstalling Translate Shell" reinstall_translate; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    html2text)
      if loading "Reinstalling html2text" reinstall_html2text; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    jq)
      if loading "Reinstalling jq" reinstall_jq; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    bc)
      if loading "Reinstalling bc" reinstall_bc; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    tree)
      if loading "Reinstalling Tree" reinstall_tree; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    fzf)
      if loading "Reinstalling Fzf" reinstall_fzf; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    imagemagick)
      if loading "Reinstalling ImageMagick" reinstall_imagemagick; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    shfmt)
      if loading "Reinstalling Shfmt" reinstall_shfmt; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    make)
      if loading "Reinstalling Make" reinstall_make; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    udocker)
      if loading "Reinstalling Udocker" reinstall_udocker; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    esac
  done

  return 0
}