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

source "$(dirname "$BASH_SOURCE")/gh.sh"
source "$(dirname "$BASH_SOURCE")/wget.sh"
source "$(dirname "$BASH_SOURCE")/curl.sh"
source "$(dirname "$BASH_SOURCE")/lsd.sh"
source "$(dirname "$BASH_SOURCE")/bat.sh"
source "$(dirname "$BASH_SOURCE")/proot.sh"
source "$(dirname "$BASH_SOURCE")/ncurses.sh"
source "$(dirname "$BASH_SOURCE")/tmate.sh"
source "$(dirname "$BASH_SOURCE")/cloudflared.sh"
source "$(dirname "$BASH_SOURCE")/translate.sh"
source "$(dirname "$BASH_SOURCE")/html2text.sh"
source "$(dirname "$BASH_SOURCE")/jq.sh"
source "$(dirname "$BASH_SOURCE")/bc.sh"
source "$(dirname "$BASH_SOURCE")/tree.sh"
source "$(dirname "$BASH_SOURCE")/fzf.sh"
source "$(dirname "$BASH_SOURCE")/imagemagick.sh"
source "$(dirname "$BASH_SOURCE")/shfmt.sh"
source "$(dirname "$BASH_SOURCE")/make.sh"
source "$(dirname "$BASH_SOURCE")/udocker.sh"

install_all_tools() {
	local installed_count=0
	local failed_count=0

	for tool in "${TOOLS_PACKAGES[@]}"; do
		case "$tool" in
		gh)
			if install_gh; then ((installed_count++)); else ((failed_count++)); fi
			;;
		wget)
			if install_wget; then ((installed_count++)); else ((failed_count++)); fi
			;;
		curl)
			if install_curl; then ((installed_count++)); else ((failed_count++)); fi
			;;
		lsd)
			if install_lsd; then ((installed_count++)); else ((failed_count++)); fi
			;;
		bat)
			if install_bat; then ((installed_count++)); else ((failed_count++)); fi
			;;
		proot)
			if install_proot; then ((installed_count++)); else ((failed_count++)); fi
			;;
		ncurses)
			if install_ncurses; then ((installed_count++)); else ((failed_count++)); fi
			;;
		tmate)
			if install_tmate; then ((installed_count++)); else ((failed_count++)); fi
			;;
		cloudflared)
			if install_cloudflared; then ((installed_count++)); else ((failed_count++)); fi
			;;
		translate)
			if install_translate; then ((installed_count++)); else ((failed_count++)); fi
			;;
		html2text)
			if install_html2text; then ((installed_count++)); else ((failed_count++)); fi
			;;
		jq)
			if install_jq; then ((installed_count++)); else ((failed_count++)); fi
			;;
		bc)
			if install_bc; then ((installed_count++)); else ((failed_count++)); fi
			;;
		tree)
			if install_tree; then ((installed_count++)); else ((failed_count++)); fi
			;;
		fzf)
			if install_fzf; then ((installed_count++)); else ((failed_count++)); fi
			;;
		imagemagick)
			if install_imagemagick; then ((installed_count++)); else ((failed_count++)); fi
			;;
		shfmt)
			if install_shfmt; then ((installed_count++)); else ((failed_count++)); fi
			;;
		make)
			if install_make; then ((installed_count++)); else ((failed_count++)); fi
			;;
		udocker)
			if install_udocker; then ((installed_count++)); else ((failed_count++)); fi
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
			if uninstall_gh; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		wget)
			if uninstall_wget; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		curl)
			if uninstall_curl; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		lsd)
			if uninstall_lsd; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		bat)
			if uninstall_bat; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		proot)
			if uninstall_proot; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		ncurses)
			if uninstall_ncurses; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		tmate)
			if uninstall_tmate; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		cloudflared)
			if uninstall_cloudflared; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		translate)
			if uninstall_translate; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		html2text)
			if uninstall_html2text; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		jq)
			if uninstall_jq; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		bc)
			if uninstall_bc; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		tree)
			if uninstall_tree; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		fzf)
			if uninstall_fzf; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		imagemagick)
			if uninstall_imagemagick; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		shfmt)
			if uninstall_shfmt; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		make)
			if uninstall_make; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		udocker)
			if uninstall_udocker; then ((uninstalled_count++)); else ((failed_count++)); fi
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
			if update_gh; then ((updated_count++)); else ((failed_count++)); fi
			;;
		wget)
			if update_wget; then ((updated_count++)); else ((failed_count++)); fi
			;;
		curl)
			if update_curl; then ((updated_count++)); else ((failed_count++)); fi
			;;
		lsd)
			if update_lsd; then ((updated_count++)); else ((failed_count++)); fi
			;;
		bat)
			if update_bat; then ((updated_count++)); else ((failed_count++)); fi
			;;
		proot)
			if update_proot; then ((updated_count++)); else ((failed_count++)); fi
			;;
		ncurses)
			if update_ncurses; then ((updated_count++)); else ((failed_count++)); fi
			;;
		tmate)
			if update_tmate; then ((updated_count++)); else ((failed_count++)); fi
			;;
		cloudflared)
			if update_cloudflared; then ((updated_count++)); else ((failed_count++)); fi
			;;
		translate)
			if update_translate; then ((updated_count++)); else ((failed_count++)); fi
			;;
		html2text)
			if update_html2text; then ((updated_count++)); else ((failed_count++)); fi
			;;
		jq)
			if update_jq; then ((updated_count++)); else ((failed_count++)); fi
			;;
		bc)
			if update_bc; then ((updated_count++)); else ((failed_count++)); fi
			;;
		tree)
			if update_tree; then ((updated_count++)); else ((failed_count++)); fi
			;;
		fzf)
			if update_fzf; then ((updated_count++)); else ((failed_count++)); fi
			;;
		imagemagick)
			if update_imagemagick; then ((updated_count++)); else ((failed_count++)); fi
			;;
		shfmt)
			if update_shfmt; then ((updated_count++)); else ((failed_count++)); fi
			;;
		make)
			if update_make; then ((updated_count++)); else ((failed_count++)); fi
			;;
		udocker)
			if update_udocker; then ((updated_count++)); else ((failed_count++)); fi
			;;
		esac
	done

	return 0
}