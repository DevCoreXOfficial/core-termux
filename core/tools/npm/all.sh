#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_npm.log"

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
	"turbopack"
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
source "$(dirname "$BASH_SOURCE")/turbopack/install.sh"

install_all_npm_packages() {
	local installed_count=0
	local failed_count=0

	for tool in "${NODE_PACKAGES[@]}"; do
		case "$tool" in
		typescript)
			loading "Installing TypeScript" install_typescript
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		nestjs)
			loading "Installing NestJS CLI" install_nestjs
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		prettier)
			loading "Installing Prettier" install_prettier
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		live-server)
			loading "Installing Live Server" install_live_server
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		localtunnel)
			loading "Installing Localtunnel" install_localtunnel
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		vercel)
			loading "Installing Vercel CLI" install_vercel
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		markserv)
			loading "Installing Markserv" install_markserv
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		psqlformat)
			loading "Installing PSQL Format" install_psqlformat
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		ncu)
			loading "Installing NPM Check Updates" install_ncu
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		ngrok)
			loading "Installing Ngrok" install_ngrok
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		turbopack)
			loading "Installing Turbopack toolchain" install_turbopack
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		esac
	done

	return 0
}

uninstall_all_npm_packages() {
	local uninstalled_count=0
	local failed_count=0

	for tool in "${NODE_PACKAGES[@]}"; do
		case "$tool" in
		typescript)
			loading "Uninstalling TypeScript" uninstall_typescript
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		nestjs)
			loading "Uninstalling NestJS CLI" uninstall_nestjs
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		prettier)
			loading "Uninstalling Prettier" uninstall_prettier
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		live-server)
			loading "Uninstalling Live Server" uninstall_live_server
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		localtunnel)
			loading "Uninstalling Localtunnel" uninstall_localtunnel
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		vercel)
			loading "Uninstalling Vercel CLI" uninstall_vercel
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		markserv)
			loading "Uninstalling Markserv" uninstall_markserv
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		psqlformat)
			loading "Uninstalling PSQL Format" uninstall_psqlformat
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		ncu)
			loading "Uninstalling NPM Check Updates" uninstall_ncu
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		ngrok)
			loading "Uninstalling Ngrok" uninstall_ngrok
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		turbopack)
			loading "Uninstalling Turbopack toolchain" uninstall_turbopack
			((uninstalled_count++))
			;;
		esac
	done

	return 0
}

update_all_npm_packages() {
  local updated_count=0
  local failed_count=0

  for tool in "${NODE_PACKAGES[@]}"; do
    case "$tool" in
    typescript)
      loading "Updating TypeScript" update_typescript
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    nestjs)
      loading "Updating NestJS CLI" update_nestjs
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    prettier)
      loading "Updating Prettier" update_prettier
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    live-server)
      loading "Updating Live Server" update_live_server
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    localtunnel)
      loading "Updating Localtunnel" update_localtunnel
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    vercel)
      loading "Updating Vercel CLI" update_vercel
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    markserv)
      loading "Updating Markserv" update_markserv
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    psqlformat)
      loading "Updating PSQL Format" update_psqlformat
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    ncu)
      loading "Updating NPM Check Updates" update_ncu
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    ngrok)
      loading "Updating Ngrok" update_ngrok
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    turbopack)
      loading "Updating Turbopack toolchain" update_turbopack
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    esac
  done

  return 0
}

reinstall_all_npm_packages() {
  local reinstalled_count=0
  local failed_count=0

  for tool in "${NODE_PACKAGES[@]}"; do
    case "$tool" in
    typescript)
      loading "Reinstalling TypeScript" reinstall_typescript
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    nestjs)
      loading "Reinstalling NestJS CLI" reinstall_nestjs
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    prettier)
      loading "Reinstalling Prettier" reinstall_prettier
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    live-server)
      loading "Reinstalling Live Server" reinstall_live_server
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    localtunnel)
      loading "Reinstalling Localtunnel" reinstall_localtunnel
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    vercel)
      loading "Reinstalling Vercel CLI" reinstall_vercel
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    markserv)
      loading "Reinstalling Markserv" reinstall_markserv
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    psqlformat)
      loading "Reinstalling PSQL Format" reinstall_psqlformat
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    ncu)
      loading "Reinstalling NPM Check Updates" reinstall_ncu
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    ngrok)
      loading "Reinstalling Ngrok" reinstall_ngrok
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    turbopack)
      loading "Reinstalling Turbopack toolchain" reinstall_turbopack
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    esac
  done

  return 0
}