#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_node_modules.log"

NODE_PACKAGES=(
	"typescript"
	"nestjs"
	"prettier"
	"live-server"
	"localtunnel"
	"vercel"
	"markserv"
	"psqlformat"
	"ncu"
	"ngrok"
)

source "$(dirname "$BASH_SOURCE")/typescript/install.sh"
source "$(dirname "$BASH_SOURCE")/nestjs/install.sh"
source "$(dirname "$BASH_SOURCE")/prettier/install.sh"
source "$(dirname "$BASH_SOURCE")/live-server/install.sh"
source "$(dirname "$BASH_SOURCE")/localtunnel/install.sh"
source "$(dirname "$BASH_SOURCE")/vercel/install.sh"
source "$(dirname "$BASH_SOURCE")/markserv/install.sh"
source "$(dirname "$BASH_SOURCE")/psqlformat/install.sh"
source "$(dirname "$BASH_SOURCE")/ncu/install.sh"
source "$(dirname "$BASH_SOURCE")/ngrok/install.sh"

install_all_node_packages() {
	local installed_count=0
	local failed_count=0

	for tool in "${NODE_PACKAGES[@]}"; do
		case "$tool" in
		typescript)
			if loading "Installing TypeScript" install_typescript; then ((installed_count++)); else ((failed_count++)); fi
			;;
		nestjs)
			if loading "Installing NestJS CLI" install_nestjs; then ((installed_count++)); else ((failed_count++)); fi
			;;
		prettier)
			if loading "Installing Prettier" install_prettier; then ((installed_count++)); else ((failed_count++)); fi
			;;
		live-server)
			if loading "Installing Live Server" install_live_server; then ((installed_count++)); else ((failed_count++)); fi
			;;
		localtunnel)
			if loading "Installing Localtunnel" install_localtunnel; then ((installed_count++)); else ((failed_count++)); fi
			;;
		vercel)
			if loading "Installing Vercel CLI" install_vercel; then ((installed_count++)); else ((failed_count++)); fi
			;;
		markserv)
			if loading "Installing Markserv" install_markserv; then ((installed_count++)); else ((failed_count++)); fi
			;;
		psqlformat)
			if loading "Installing PSQL Format" install_psqlformat; then ((installed_count++)); else ((failed_count++)); fi
			;;
		ncu)
			if loading "Installing NPM Check Updates" install_ncu; then ((installed_count++)); else ((failed_count++)); fi
			;;
		ngrok)
			if loading "Installing Ngrok" install_ngrok; then ((installed_count++)); else ((failed_count++)); fi
			;;
		esac
	done

	return 0
}

uninstall_all_node_packages() {
	local uninstalled_count=0
	local failed_count=0

	for tool in "${NODE_PACKAGES[@]}"; do
		case "$tool" in
		typescript)
			if loading "Uninstalling TypeScript" uninstall_typescript; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		nestjs)
			if loading "Uninstalling NestJS CLI" uninstall_nestjs; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		prettier)
			if loading "Uninstalling Prettier" uninstall_prettier; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		live-server)
			if loading "Uninstalling Live Server" uninstall_live_server; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		localtunnel)
			if loading "Uninstalling Localtunnel" uninstall_localtunnel; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		vercel)
			if loading "Uninstalling Vercel CLI" uninstall_vercel; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		markserv)
			if loading "Uninstalling Markserv" uninstall_markserv; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		psqlformat)
			if loading "Uninstalling PSQL Format" uninstall_psqlformat; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		ncu)
			if loading "Uninstalling NPM Check Updates" uninstall_ncu; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		ngrok)
			if loading "Uninstalling Ngrok" uninstall_ngrok; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		esac
	done

	return 0
}

update_all_node_packages() {
  local updated_count=0
  local failed_count=0

  for tool in "${NODE_PACKAGES[@]}"; do
    case "$tool" in
    typescript)
      if loading "Updating TypeScript" update_typescript; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    nestjs)
      if loading "Updating NestJS CLI" update_nestjs; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    prettier)
      if loading "Updating Prettier" update_prettier; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    live-server)
      if loading "Updating Live Server" update_live_server; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    localtunnel)
      if loading "Updating Localtunnel" update_localtunnel; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    vercel)
      if loading "Updating Vercel CLI" update_vercel; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    markserv)
      if loading "Updating Markserv" update_markserv; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    psqlformat)
      if loading "Updating PSQL Format" update_psqlformat; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    ncu)
      if loading "Updating NPM Check Updates" update_ncu; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    ngrok)
      if loading "Updating Ngrok" update_ngrok; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    esac
  done

  return 0
}

reinstall_all_node_packages() {
  local reinstalled_count=0
  local failed_count=0

  for tool in "${NODE_PACKAGES[@]}"; do
    case "$tool" in
    typescript)
      if loading "Reinstalling TypeScript" reinstall_typescript; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    nestjs)
      if loading "Reinstalling NestJS CLI" reinstall_nestjs; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    prettier)
      if loading "Reinstalling Prettier" reinstall_prettier; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    live-server)
      if loading "Reinstalling Live Server" reinstall_live_server; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    localtunnel)
      if loading "Reinstalling Localtunnel" reinstall_localtunnel; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    vercel)
      if loading "Reinstalling Vercel CLI" reinstall_vercel; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    markserv)
      if loading "Reinstalling Markserv" reinstall_markserv; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    psqlformat)
      if loading "Reinstalling PSQL Format" reinstall_psqlformat; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    ncu)
      if loading "Reinstalling NPM Check Updates" reinstall_ncu; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    ngrok)
      if loading "Reinstalling Ngrok" reinstall_ngrok; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    esac
  done

  return 0
}