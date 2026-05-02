#!/bin/bash

import "@/utils/log"
import "@/fix/localtunnel"

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

source "$(dirname "$BASH_SOURCE")/typescript.sh"
source "$(dirname "$BASH_SOURCE")/nestjs.sh"
source "$(dirname "$BASH_SOURCE")/prettier.sh"
source "$(dirname "$BASH_SOURCE")/live-server.sh"
source "$(dirname "$BASH_SOURCE")/localtunnel.sh"
source "$(dirname "$BASH_SOURCE")/vercel.sh"
source "$(dirname "$BASH_SOURCE")/markserv.sh"
source "$(dirname "$BASH_SOURCE")/psqlformat.sh"
source "$(dirname "$BASH_SOURCE")/ncu.sh"
source "$(dirname "$BASH_SOURCE")/ngrok.sh"

install_all_node_packages() {
	local installed_count=0
	local failed_count=0

	for tool in "${NODE_PACKAGES[@]}"; do
		case "$tool" in
		typescript)
			if install_typescript; then ((installed_count++)); else ((failed_count++)); fi
			;;
		nestjs)
			if install_nestjs; then ((installed_count++)); else ((failed_count++)); fi
			;;
		prettier)
			if install_prettier; then ((installed_count++)); else ((failed_count++)); fi
			;;
		live-server)
			if install_live_server; then ((installed_count++)); else ((failed_count++)); fi
			;;
		localtunnel)
			if install_localtunnel; then ((installed_count++)); else ((failed_count++)); fi
			;;
		vercel)
			if install_vercel; then ((installed_count++)); else ((failed_count++)); fi
			;;
		markserv)
			if install_markserv; then ((installed_count++)); else ((failed_count++)); fi
			;;
		psqlformat)
			if install_psqlformat; then ((installed_count++)); else ((failed_count++)); fi
			;;
		ncu)
			if install_ncu; then ((installed_count++)); else ((failed_count++)); fi
			;;
		ngrok)
			if install_ngrok; then ((installed_count++)); else ((failed_count++)); fi
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
			if uninstall_typescript; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		nestjs)
			if uninstall_nestjs; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		prettier)
			if uninstall_prettier; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		live-server)
			if uninstall_live_server; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		localtunnel)
			if uninstall_localtunnel; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		vercel)
			if uninstall_vercel; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		markserv)
			if uninstall_markserv; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		psqlformat)
			if uninstall_psqlformat; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		ncu)
			if uninstall_ncu; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		ngrok)
			if uninstall_ngrok; then ((uninstalled_count++)); else ((failed_count++)); fi
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
			if update_typescript; then ((updated_count++)); else ((failed_count++)); fi
			;;
		nestjs)
			if update_nestjs; then ((updated_count++)); else ((failed_count++)); fi
			;;
		prettier)
			if update_prettier; then ((updated_count++)); else ((failed_count++)); fi
			;;
		live-server)
			if update_live_server; then ((updated_count++)); else ((failed_count++)); fi
			;;
		localtunnel)
			if update_localtunnel; then ((updated_count++)); else ((failed_count++)); fi
			;;
		vercel)
			if update_vercel; then ((updated_count++)); else ((failed_count++)); fi
			;;
		markserv)
			if update_markserv; then ((updated_count++)); else ((failed_count++)); fi
			;;
		psqlformat)
			if update_psqlformat; then ((updated_count++)); else ((failed_count++)); fi
			;;
		ncu)
			if update_ncu; then ((updated_count++)); else ((failed_count++)); fi
			;;
		ngrok)
			if update_ngrok; then ((updated_count++)); else ((failed_count++)); fi
			;;
		esac
	done

	return 0
}