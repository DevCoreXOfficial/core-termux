#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_tools.log"

# ===== GITHUB CLI =====
install_gh() {
	if dpkg -s gh 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install gh -y &>>"$LOG_FILE"; then
		log_success "GitHub CLI installed"
		return 0
	else
		log_error "Failed to install GitHub CLI"
		return 1
	fi
}

uninstall_gh() {
	log_info "Uninstalling GitHub CLI..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall gh -y &>>"$LOG_FILE"; then
		log_success "GitHub CLI uninstalled"
		return 0
	else
		log_error "Failed to uninstall GitHub CLI"
		return 1
	fi
}

update_gh() {
	log_info "Updating GitHub CLI..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade gh -y &>>"$LOG_FILE"; then
		log_success "GitHub CLI updated"
		return 0
	else
		log_error "Failed to update GitHub CLI"
		return 1
	fi
}

# ===== WGET =====
install_wget() {
	if dpkg -s wget 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install wget -y &>>"$LOG_FILE"; then
		log_success "Wget installed"
		return 0
	else
		log_error "Failed to install Wget"
		return 1
	fi
}

uninstall_wget() {
	log_info "Uninstalling Wget..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall wget -y &>>"$LOG_FILE"; then
		log_success "Wget uninstalled"
		return 0
	else
		log_error "Failed to uninstall Wget"
		return 1
	fi
}

update_wget() {
	log_info "Updating Wget..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade wget -y &>>"$LOG_FILE"; then
		log_success "Wget updated"
		return 0
	else
		log_error "Failed to update Wget"
		return 1
	fi
}

# ===== CURL =====
install_curl() {
	if dpkg -s curl 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install curl -y &>>"$LOG_FILE"; then
		log_success "Curl installed"
		return 0
	else
		log_error "Failed to install Curl"
		return 1
	fi
}

uninstall_curl() {
	log_info "Uninstalling Curl..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall curl -y &>>"$LOG_FILE"; then
		log_success "Curl uninstalled"
		return 0
	else
		log_error "Failed to uninstall Curl"
		return 1
	fi
}

update_curl() {
	log_info "Updating Curl..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade curl -y &>>"$LOG_FILE"; then
		log_success "Curl updated"
		return 0
	else
		log_error "Failed to update Curl"
		return 1
	fi
}

# ===== LSD =====
install_lsd() {
	if dpkg -s lsd 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install lsd -y &>>"$LOG_FILE"; then
		log_success "LSD installed"
		return 0
	else
		log_error "Failed to install LSD"
		return 1
	fi
}

uninstall_lsd() {
	log_info "Uninstalling LSD..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall lsd -y &>>"$LOG_FILE"; then
		log_success "LSD uninstalled"
		return 0
	else
		log_error "Failed to uninstall LSD"
		return 1
	fi
}

update_lsd() {
	log_info "Updating LSD..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade lsd -y &>>"$LOG_FILE"; then
		log_success "LSD updated"
		return 0
	else
		log_error "Failed to update LSD"
		return 1
	fi
}

# ===== BAT =====
install_bat() {
	if dpkg -s bat 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install bat -y &>>"$LOG_FILE"; then
		log_success "Bat installed"
		return 0
	else
		log_error "Failed to install Bat"
		return 1
	fi
}

uninstall_bat() {
	log_info "Uninstalling Bat..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall bat -y &>>"$LOG_FILE"; then
		log_success "Bat uninstalled"
		return 0
	else
		log_error "Failed to uninstall Bat"
		return 1
	fi
}

update_bat() {
	log_info "Updating Bat..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade bat -y &>>"$LOG_FILE"; then
		log_success "Bat updated"
		return 0
	else
		log_error "Failed to update Bat"
		return 1
	fi
}

# ===== PROOT =====
install_proot() {
	if dpkg -s proot 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install proot -y &>>"$LOG_FILE"; then
		log_success "Proot installed"
		return 0
	else
		log_error "Failed to install Proot"
		return 1
	fi
}

uninstall_proot() {
	log_info "Uninstalling Proot..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall proot -y &>>"$LOG_FILE"; then
		log_success "Proot uninstalled"
		return 0
	else
		log_error "Failed to uninstall Proot"
		return 1
	fi
}

update_proot() {
	log_info "Updating Proot..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade proot -y &>>"$LOG_FILE"; then
		log_success "Proot updated"
		return 0
	else
		log_error "Failed to update Proot"
		return 1
	fi
}

# ===== NCURSES =====
install_ncurses() {
	if dpkg -s ncurses-utils 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install ncurses-utils -y &>>"$LOG_FILE"; then
		log_success "Ncurses Utils installed"
		return 0
	else
		log_error "Failed to install Ncurses Utils"
		return 1
	fi
}

uninstall_ncurses() {
	log_info "Uninstalling Ncurses Utils..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall ncurses-utils -y &>>"$LOG_FILE"; then
		log_success "Ncurses Utils uninstalled"
		return 0
	else
		log_error "Failed to uninstall Ncurses Utils"
		return 1
	fi
}

update_ncurses() {
	log_info "Updating Ncurses Utils..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade ncurses-utils -y &>>"$LOG_FILE"; then
		log_success "Ncurses Utils updated"
		return 0
	else
		log_error "Failed to update Ncurses Utils"
		return 1
	fi
}

# ===== TMATE =====
install_tmate() {
	if dpkg -s tmate 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install tmate -y &>>"$LOG_FILE"; then
		log_success "Tmate installed"
		return 0
	else
		log_error "Failed to install Tmate"
		return 1
	fi
}

uninstall_tmate() {
	log_info "Uninstalling Tmate..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall tmate -y &>>"$LOG_FILE"; then
		log_success "Tmate uninstalled"
		return 0
	else
		log_error "Failed to uninstall Tmate"
		return 1
	fi
}

update_tmate() {
	log_info "Updating Tmate..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade tmate -y &>>"$LOG_FILE"; then
		log_success "Tmate updated"
		return 0
	else
		log_error "Failed to update Tmate"
		return 1
	fi
}

# ===== CLOUDFLARED =====
install_cloudflared() {
	if dpkg -s cloudflared 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install cloudflared -y &>>"$LOG_FILE"; then
		log_success "Cloudflared installed"
		return 0
	else
		log_error "Failed to install Cloudflared"
		return 1
	fi
}

uninstall_cloudflared() {
	log_info "Uninstalling Cloudflared..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall cloudflared -y &>>"$LOG_FILE"; then
		log_success "Cloudflared uninstalled"
		return 0
	else
		log_error "Failed to uninstall Cloudflared"
		return 1
	fi
}

update_cloudflared() {
	log_info "Updating Cloudflared..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade cloudflared -y &>>"$LOG_FILE"; then
		log_success "Cloudflared updated"
		return 0
	else
		log_error "Failed to update Cloudflared"
		return 1
	fi
}

# ===== TRANSLATE SHELL =====
install_translate() {
	if dpkg -s translate-shell 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install translate-shell -y &>>"$LOG_FILE"; then
		log_success "Translate Shell installed"
		return 0
	else
		log_error "Failed to install Translate Shell"
		return 1
	fi
}

uninstall_translate() {
	log_info "Uninstalling Translate Shell..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall translate-shell -y &>>"$LOG_FILE"; then
		log_success "Translate Shell uninstalled"
		return 0
	else
		log_error "Failed to uninstall Translate Shell"
		return 1
	fi
}

update_translate() {
	log_info "Updating Translate Shell..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade translate-shell -y &>>"$LOG_FILE"; then
		log_success "Translate Shell updated"
		return 0
	else
		log_error "Failed to update Translate Shell"
		return 1
	fi
}

# ===== HTML2TEXT =====
install_html2text() {
	if dpkg -s html2text 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install html2text -y &>>"$LOG_FILE"; then
		log_success "html2text installed"
		return 0
	else
		log_error "Failed to install html2text"
		return 1
	fi
}

uninstall_html2text() {
	log_info "Uninstalling html2text..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall html2text -y &>>"$LOG_FILE"; then
		log_success "html2text uninstalled"
		return 0
	else
		log_error "Failed to uninstall html2text"
		return 1
	fi
}

update_html2text() {
	log_info "Updating html2text..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade html2text -y &>>"$LOG_FILE"; then
		log_success "html2text updated"
		return 0
	else
		log_error "Failed to update html2text"
		return 1
	fi
}

# ===== JQ =====
install_jq() {
	if dpkg -s jq 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install jq -y &>>"$LOG_FILE"; then
		log_success "jq installed"
		return 0
	else
		log_error "Failed to install jq"
		return 1
	fi
}

uninstall_jq() {
	log_info "Uninstalling jq..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall jq -y &>>"$LOG_FILE"; then
		log_success "jq uninstalled"
		return 0
	else
		log_error "Failed to uninstall jq"
		return 1
	fi
}

update_jq() {
	log_info "Updating jq..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade jq -y &>>"$LOG_FILE"; then
		log_success "jq updated"
		return 0
	else
		log_error "Failed to update jq"
		return 1
	fi
}

# ===== BC =====
install_bc() {
	if dpkg -s bc 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install bc -y &>>"$LOG_FILE"; then
		log_success "bc installed"
		return 0
	else
		log_error "Failed to install bc"
		return 1
	fi
}

uninstall_bc() {
	log_info "Uninstalling bc..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall bc -y &>>"$LOG_FILE"; then
		log_success "bc uninstalled"
		return 0
	else
		log_error "Failed to uninstall bc"
		return 1
	fi
}

update_bc() {
	log_info "Updating bc..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade bc -y &>>"$LOG_FILE"; then
		log_success "bc updated"
		return 0
	else
		log_error "Failed to update bc"
		return 1
	fi
}

# ===== TREE =====
install_tree() {
	if dpkg -s tree 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install tree -y &>>"$LOG_FILE"; then
		log_success "Tree installed"
		return 0
	else
		log_error "Failed to install Tree"
		return 1
	fi
}

uninstall_tree() {
	log_info "Uninstalling Tree..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall tree -y &>>"$LOG_FILE"; then
		log_success "Tree uninstalled"
		return 0
	else
		log_error "Failed to uninstall Tree"
		return 1
	fi
}

update_tree() {
	log_info "Updating Tree..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade tree -y &>>"$LOG_FILE"; then
		log_success "Tree updated"
		return 0
	else
		log_error "Failed to update Tree"
		return 1
	fi
}

# ===== FZF =====
install_fzf() {
	if dpkg -s fzf 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install fzf -y &>>"$LOG_FILE"; then
		log_success "Fzf installed"
		return 0
	else
		log_error "Failed to install Fzf"
		return 1
	fi
}

uninstall_fzf() {
	log_info "Uninstalling Fzf..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall fzf -y &>>"$LOG_FILE"; then
		log_success "Fzf uninstalled"
		return 0
	else
		log_error "Failed to uninstall Fzf"
		return 1
	fi
}

update_fzf() {
	log_info "Updating Fzf..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade fzf -y &>>"$LOG_FILE"; then
		log_success "Fzf updated"
		return 0
	else
		log_error "Failed to update Fzf"
		return 1
	fi
}

# ===== IMAGEMAGICK =====
install_imagemagick() {
	if dpkg -s imagemagick 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install imagemagick -y &>>"$LOG_FILE"; then
		log_success "ImageMagick installed"
		return 0
	else
		log_error "Failed to install ImageMagick"
		return 1
	fi
}

uninstall_imagemagick() {
	log_info "Uninstalling ImageMagick..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall imagemagick -y &>>"$LOG_FILE"; then
		log_success "ImageMagick uninstalled"
		return 0
	else
		log_error "Failed to uninstall ImageMagick"
		return 1
	fi
}

update_imagemagick() {
	log_info "Updating ImageMagick..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade imagemagick -y &>>"$LOG_FILE"; then
		log_success "ImageMagick updated"
		return 0
	else
		log_error "Failed to update ImageMagick"
		return 1
	fi
}

# ===== SHFMT =====
install_shfmt() {
	if dpkg -s shfmt 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install shfmt -y &>>"$LOG_FILE"; then
		log_success "Shfmt installed"
		return 0
	else
		log_error "Failed to install Shfmt"
		return 1
	fi
}

uninstall_shfmt() {
	log_info "Uninstalling Shfmt..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall shfmt -y &>>"$LOG_FILE"; then
		log_success "Shfmt uninstalled"
		return 0
	else
		log_error "Failed to uninstall Shfmt"
		return 1
	fi
}

update_shfmt() {
	log_info "Updating Shfmt..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade shfmt -y &>>"$LOG_FILE"; then
		log_success "Shfmt updated"
		return 0
	else
		log_error "Failed to update Shfmt"
		return 1
	fi
}

# ===== MAKE =====
install_make() {
	if dpkg -s make 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install make -y &>>"$LOG_FILE"; then
		log_success "Make installed"
		return 0
	else
		log_error "Failed to install Make"
		return 1
	fi
}

uninstall_make() {
	log_info "Uninstalling Make..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall make -y &>>"$LOG_FILE"; then
		log_success "Make uninstalled"
		return 0
	else
		log_error "Failed to uninstall Make"
		return 1
	fi
}

update_make() {
	log_info "Updating Make..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade make -y &>>"$LOG_FILE"; then
		log_success "Make updated"
		return 0
	else
		log_error "Failed to update Make"
		return 1
	fi
}

# ===== UDOCKER =====
install_udocker() {
  if dpkg -s udocker 2>/dev/null | grep -q "Status: install ok installed"; then
    return 0
  fi

mkdir -p "$(dirname "$LOG_FILE")"

  if pkg install udocker -y &>>"$LOG_FILE"; then
    log_success "Udocker installed"
    return 0
  else
    log_error "Failed to install Udocker"
    return 1
  fi
}

uninstall_udocker() {
  log_info "Uninstalling Udocker..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if pkg uninstall udocker -y &>>"$LOG_FILE"; then
    log_success "Udocker uninstalled"
    return 0
  else
    log_error "Failed to uninstall Udocker"
    return 1
  fi
}

update_udocker() {
  log_info "Updating Udocker..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if pkg upgrade udocker -y &>>"$LOG_FILE"; then
    log_success "Udocker updated"
    return 0
  else
    log_error "Failed to update Udocker"
    return 1
  fi
}
