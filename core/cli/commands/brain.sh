#!/usr/bin/env bash

import "@/utils/log"
import "@/utils/colors"

readonly BRAIN_DIR="$CORE_DATA/brain"

# ── Helpers ──────────────────────────────────────────────────

_brain_ensure() {
	if [[ ! -d "$BRAIN_DIR" ]]; then
		log_error "Brain not initialized"
		list_item "Run: ${D_CYAN}core brain init${D_NC}"
		return 1
	fi
}

_brain_slug() {
	local title="$1"
	local slug
	slug=$(echo "$title" \
		| tr '[:upper:]' '[:lower:]' \
		| sed -E 's/[^a-z0-9]+/-/g' \
		| sed -E 's/^-+|-+$//g' \
		| cut -c1-60)
	echo "$slug"
}

_brain_frontmatter() {
	local title="$1" tags="$2" category="$3" related="$4"
	cat <<-EOF
	---
	title: $title
	tags: [$tags]
	created: $(date +%Y-%m-%d)
	category: $category
	EOF
	if [[ -n "$related" ]]; then
		echo "related: [$related]"
	fi
	echo "---"
}

_brain_title() {
	local file="$1"
	local t
	t=$(grep -m1 '^title: ' "$file" 2>/dev/null | sed 's/^title: //')
	if [[ -n "$t" ]]; then
		echo "$t"
	else
		local fallback
		fallback=$(grep -m1 '^# ' "$file" 2>/dev/null | sed 's/^# //')
		echo "${fallback:-$(basename "$file" .md)}"
	fi
}

_brain_update_related() {
	local file="$1" slug="$2"
	local tmp
	tmp=$(mktemp)
	local frontmatter_end
	frontmatter_end=$(awk '/^---$/ {++n} n==2 {print NR; exit}' "$file")

	if [[ -z "$frontmatter_end" ]]; then
		rm -f "$tmp"
		return
	fi

	head -n $((frontmatter_end - 1)) "$file" >"$tmp"

	if grep -q "related:.*$slug" "$tmp" 2>/dev/null; then
		rm -f "$tmp"
		return
	fi

	if grep -q "^related:" "$tmp" 2>/dev/null; then
		sed -i "s/^related: \[\(.*\)\]/related: [\1, $slug]/" "$tmp"
	else
		sed -i "/^---$/a related: [$slug]" "$tmp"
	fi
	tail -n +$((frontmatter_end)) "$file" >>"$tmp"
	mv "$tmp" "$file"
}

_brain_remove_related() {
	local file="$1" slug="$2"
	local tmp
	tmp=$(mktemp)
	local frontmatter_end
	frontmatter_end=$(awk '/^---$/ {++n} n==2 {print NR; exit}' "$file")

	if [[ -z "$frontmatter_end" ]]; then
		rm -f "$tmp"
		return
	fi

	head -n $((frontmatter_end - 1)) "$file" >"$tmp"
	sed -i "s/related: \[\(.*\)$slug\(.*\)\]/related: [\1\2]/" "$tmp"
	sed -i 's/related: \[, */related: [/; s/, *, */, /g; s/related: \[ *\]//' "$tmp"
	tail -n +$((frontmatter_end)) "$file" >>"$tmp"
	mv "$tmp" "$file"
}

_brain_pick_file() {
	local prompt="$1"
	local -a files=()

	while IFS= read -r f; do
		files+=("$f")
	done < <(find "$BRAIN_DIR" -name "*.md" ! -name "README.md" 2>/dev/null | sort)

	if [[ ${#files[@]} -eq 0 ]]; then
		echo ""
		return
	fi

	local idx=0
	for f in "${files[@]}"; do
		local t
		t=$(_brain_title "$f")
		printf "    ${D_GREEN}%2d.${D_NC} %s\n" $((idx + 1)) "$t" >&2
		((idx++))
	done

	echo >&2
	read_input "$prompt" pick

	if [[ -z "$pick" ]]; then
		echo ""
		return
	fi

	local selected=""
	if [[ "$pick" =~ ^[0-9]+$ ]] && ((pick >= 1 && pick <= ${#files[@]})); then
		selected="${files[$((pick - 1))]}"
	else
		for f in "${files[@]}"; do
			local t
			t=$(_brain_title "$f")
			if echo "$t" | grep -qi "$pick"; then
				selected="$f"
				break
			fi
		done
	fi

	echo "$selected"
}

_brain_editor() {
	local title="$1"

	if ! command -v nvim &>/dev/null; then
		log_error "Neovim not found"
		list_item "Install it: ${D_CYAN}core install editor${D_NC}"
		return 1
	fi

	local tmpfile
	tmpfile=$(mktemp)

	echo "# $title" >"$tmpfile"
	echo >>"$tmpfile"
	echo "- " >>"$tmpfile"

	nvim "$tmpfile" </dev/tty >/dev/tty

	local lines
	lines=$(wc -l <"$tmpfile")
	if ((lines <= 2)); then
		rm -f "$tmpfile"
		return 1
	fi

	echo "$tmpfile"
}

# ── Help ────────────────────────────────────────────────────

brain_help() {
	echo
	box_large "Core Brain — Your Second Brain"
	echo
	log_info "Usage: core brain <subcommand> [options]"
	echo
	separator_section "Subcommands"
	echo
	printf "    ${D_CYAN}%-12s${D_NC} %s\n" "init" "Initialize brain directory and GitHub repo"
	printf "    ${D_CYAN}%-12s${D_NC} %s\n" "save" "Save a new memory interactively"
	printf "    ${D_CYAN}%-12s${D_NC} %s\n" "search" "Search memories by keywords or tags"
	printf "    ${D_CYAN}%-12s${D_NC} %s\n" "ls" "List memories by category"
	printf "    ${D_CYAN}%-12s${D_NC} %s\n" "edit" "Edit a memory in your \$EDITOR"
	printf "    ${D_CYAN}%-12s${D_NC} %s\n" "delete" "Delete a memory permanently"
	printf "    ${D_CYAN}%-12s${D_NC} %s\n" "reset" "Destroy the entire brain"
	printf "    ${D_CYAN}%-12s${D_NC} %s\n" "show" "View a memory with its relations"
	printf "    ${D_CYAN}%-12s${D_NC} %s\n" "graph" "Visual map of all connections"
	printf "    ${D_CYAN}%-12s${D_NC} %s\n" "skill" "Create an AI skill from memories"
	printf "    ${D_CYAN}%-12s${D_NC} %s\n" "relate" "Link two memories"
	printf "    ${D_CYAN}%-12s${D_NC} %s\n" "sync" "Push/pull to GitHub private repo"
	echo
	separator_section "Examples"
	echo
	printf "    ${D_CYAN}core brain init${D_NC}              # Create local brain\n"
	printf "    ${D_CYAN}core brain save${D_NC}              # Interactive save\n"
	printf "    ${D_CYAN}core brain search react${D_NC}      # Search all memories\n"
	printf "    ${D_CYAN}core brain ls${D_NC}                # List all categories\n"
	printf "    ${D_CYAN}core brain ls react${D_NC}          # List react category\n"
	printf "    ${D_CYAN}core brain edit${D_NC}              # Interactive edit\n"
	printf "    ${D_CYAN}core brain edit slug-name${D_NC}    # Edit by slug\n"
	printf "    ${D_CYAN}core brain delete${D_NC}            # Interactive delete\n"
	printf "    ${D_CYAN}core brain reset${D_NC}             # Destroy local brain\n"
	printf "    ${D_CYAN}core brain show slug-name${D_NC}    # View memory + relations\n"
	printf "    ${D_CYAN}core brain graph${D_NC}             # Show connection map\n"
	printf "    ${D_CYAN}core brain skill${D_NC}             # Create a skill from memories\n"
	printf "    ${D_CYAN}core brain sync${D_NC}              # Sync with GitHub\n"
	echo
	separator_section "Non-interactive flags (AI agent mode)"
	echo
	printf "    ${D_CYAN}core brain save --title \"T\" --content \"C\" [--category c] [--tags \"a, b\"]${D_NC}\n"
	printf "    ${D_CYAN}core brain search \"query\" --full${D_NC}\n"
	printf "    ${D_CYAN}core brain edit <slug> --content \"new text\"${D_NC}\n"
	printf "    ${D_CYAN}core brain delete <slug> --yes${D_NC}\n"
	printf "    ${D_CYAN}core brain graph --json${D_NC}\n"
	printf "    ${D_CYAN}core brain skill --all --name <name> [--global]${D_NC}\n"
	echo
	list_item "These skip all prompts — used by ${D_CYAN}core agent${D_NC}, scripts and the REPL shell mode"
	echo
}

# ── Init ────────────────────────────────────────────────────

brain_init() {
	separator
	box_large "Initialize Core Brain"
	separator
	echo

	if [[ -d "$BRAIN_DIR" ]]; then
		log_warn "Brain already exists at: ${D_CYAN}$BRAIN_DIR${D_NC}"
		separator
		return 0
	fi

	local gh_ok=false
	if command -v gh &>/dev/null && gh auth status &>/dev/null; then
		gh_ok=true
	fi

	if ! $gh_ok; then
		mkdir -p "$BRAIN_DIR"
		log_success "Local brain created: ${D_CYAN}$BRAIN_DIR${D_NC}"
		list_item "Install gh for GitHub sync: ${D_CYAN}core install dev${D_NC}"
		separator
		return 0
	fi

	local gh_user
	gh_user=$(gh api user --jq '.login' 2>/dev/null)
	local repo_name="core-brain"

	if gh repo view "$gh_user/$repo_name" &>/dev/null; then
		log_info "Found existing brain repo: ${D_CYAN}$gh_user/$repo_name${D_NC}"
		echo
		read_confirm "Clone it to restore your memories?" confirm
		if [[ "$confirm" == "y" ]]; then
			loading "Cloning repository..." gh repo clone "$gh_user/$repo_name" "$BRAIN_DIR"
			log_success "Brain restored from GitHub"
			separator
			return 0
		fi
	fi

	mkdir -p "$BRAIN_DIR"
	log_success "Local brain created: ${D_CYAN}$BRAIN_DIR${D_NC}"
	echo

	read_confirm "Create a private GitHub repo for your brain?" confirm
	if [[ "$confirm" != "y" ]]; then
		log_info "Skipping GitHub setup. You can set it up later."
		separator
		return 0
	fi

	log_info "Creating private repo: ${D_CYAN}$gh_user/$repo_name${D_NC}..."
	if gh repo create "$repo_name" --private &>/dev/null; then
		cd "$BRAIN_DIR" || return 1
		git init &>/dev/null
		echo "# Core Brain" >README.md
		git add -A
		git commit -m "init brain" &>/dev/null
		git remote add origin "https://github.com/$gh_user/$repo_name.git"
		loading "Pushing to GitHub..." git push -u origin main
		log_success "Repo created and linked: ${D_CYAN}https://github.com/$gh_user/$repo_name${D_NC}"
	else
		log_warn "Failed to create repo. Check your permissions."
	fi

	separator
}

# ── Save ────────────────────────────────────────────────────

brain_save() {
	_brain_ensure || return 1

	# ── Non-interactive flags (used by the AI agent) ──
	local title="" content="" category="" tags_input=""
	local flags=0
	while [[ $# -gt 0 ]]; do
		case "$1" in
		--title) title="$2"; flags=1; shift 2 ;;
		--content) content="$2"; flags=1; shift 2 ;;
		--category) category="$2"; flags=1; shift 2 ;;
		--tags) tags_input="$2"; flags=1; shift 2 ;;
		--yes) flags=1; shift ;;
		*) shift ;;
		esac
	done

	separator
	box_large "Save a New Memory"
	separator
	echo

	if [[ -z "$title" ]]; then
		read_input "Title" title
	fi
	if [[ -z "$title" ]]; then
		log_error "Title cannot be empty"
		separator
		return 1
	fi

	local slug
	slug=$(_brain_slug "$title")
	local date_prefix
	date_prefix=$(date +%Y-%m-%d)

	# ── Categories ──
	if [[ -z "$category" ]]; then
		if (( flags == 1 )); then
			category="general"
		else
			local categories
			categories=$(find "$BRAIN_DIR" -mindepth 1 -maxdepth 1 -type d ! -name ".git" -exec basename {} \; 2>/dev/null | sort)
			echo
			if [[ -n "$categories" ]]; then
				log_info "Existing categories:"
				echo
				while IFS= read -r cat; do
					printf "    ${D_GREEN}•${D_NC} ${D_CYAN}%s${D_NC}\n" "$cat"
				done <<<"$categories"
				echo
			fi
			read_input "Category" category
			[[ -z "$category" ]] && category="general"
		fi
	fi

	# ── Tags ──
	if [[ -z "$tags_input" ]] && (( flags != 1 )); then
		read_input "Tags (comma separated)" tags_input
	fi
	tags_input="${tags_input:-}"
	local tags_formatted
	tags_formatted=$(echo "$tags_input" | sed 's/, */, /g' | sed 's/^, \|, $//g')

	# ── Content ──
	if (( flags == 1 )) && [[ -z "$content" ]]; then
		log_error "Missing --content for non-interactive save"
		separator
		return 1
	fi
	local tmpfile
	if [[ -z "$content" ]]; then
		tmpfile=$(_brain_editor "$title")
		if [[ -z "$tmpfile" ]]; then
			log_error "Content cannot be empty"
			return 1
		fi
		content=$(cat "$tmpfile")
		rm -f "$tmpfile"
	fi

	# ── Suggest relations ──
	local -a related_slugs=()
	if [[ "$flags" != "1" ]] && [[ -n "$tags_formatted" ]]; then
		local IFS=','
		for tag in $tags_formatted; do
			tag=$(echo "$tag" | xargs)
			while IFS= read -r match; do
				local match_slug
				match_slug=$(basename "$match" .md)
				# Don't relate to self and avoid duplicates
				if [[ "$match_slug" != "${date_prefix}_${slug}" ]]; then
					local already=false
					for r in "${related_slugs[@]}"; do
						[[ "$r" == "$match_slug" ]] && already=true && break
					done
					$already || related_slugs+=("$match_slug")
				fi
			done < <(rg -l -i "tags:.*$tag" "$BRAIN_DIR" 2>/dev/null || true)
		done
		IFS=$' \t\n'

		if [[ ${#related_slugs[@]} -gt 0 ]]; then
			echo
			log_info "Found ${#related_slugs[@]} related memory(ies) with shared tags:"
			for r in "${related_slugs[@]}"; do
				local rfile
				rfile=$(find "$BRAIN_DIR" -name "${r}.md" 2>/dev/null | head -1)
				local r_title
				r_title=$(_brain_title "$rfile")
				printf "    ${D_GREEN}•${D_NC} %s\n" "${r_title:-$r}"
			done
			read_confirm "Link these relations?" link_confirm
			if [[ "$link_confirm" != "y" ]]; then
				related_slugs=()
			fi
		fi
	fi

	# ── Build related string ──
	local related_str=""
	if [[ ${#related_slugs[@]} -gt 0 ]]; then
		related_str=$(IFS=,; echo "${related_slugs[*]}")
	fi

	# ── Write file ──
	mkdir -p "$BRAIN_DIR/$category"
	local filepath="$BRAIN_DIR/$category/${date_prefix}_${slug}.md"

	{
		_brain_frontmatter "$title" "$tags_formatted" "$category" "$related_str"
		echo
		echo "$content"
	} >"$filepath"

	# ── Write reverse relations ──
	if [[ -n "$related_str" ]]; then
		local IFS=','
		for rslug in $related_str; do
			rslug=$(echo "$rslug" | xargs)
			local rfile
			rfile=$(find "$BRAIN_DIR" -name "${rslug}.md" 2>/dev/null | head -1)
			if [[ -n "$rfile" ]]; then
				_brain_update_related "$rfile" "${date_prefix}_${slug}"
			fi
		done
		IFS=$' \t\n'
	fi

	echo
	log_success "Memory saved to ${D_CYAN}$category/${date_prefix}_${slug}.md${D_NC}"

	if [[ "$flags" != "1" ]] && command -v bat &>/dev/null; then
		read_confirm "Preview with bat?" preview
		if [[ "$preview" == "y" ]]; then
			bat "$filepath"
		fi
	fi

	echo
}

# ── Search ──────────────────────────────────────────────────

brain_search() {
	_brain_ensure || return 1

	# ── --full: non-interactive, print the whole matched memories ──
	local full=0
	local -a args=()
	local a
	for a in "$@"; do
		if [[ "$a" == "--full" ]]; then
			full=1
		else
			args+=("$a")
		fi
	done
	local query="${args[*]}"
	if [[ -z "$query" ]]; then
		read_input "Search query" query
	fi
	if [[ -z "$query" ]]; then
		return 0
	fi

	separator
	box_large "Search: $query"
	separator
	echo

	if ! command -v rg &>/dev/null; then
		log_error "ripgrep not found — this shouldn't happen"
		return 1
	fi

	local -a results=()
	while IFS=':' read -r file line content; do
		results+=("$file|$line|$content")
	done < <(rg -n -i "$query" "$BRAIN_DIR" --glob '*.md' --no-heading 2>/dev/null || true)

	if [[ ${#results[@]} -eq 0 ]]; then
		log_warn "No results for: $query"
		return 0
	fi

	# ── --full: print every matching memory (title + full content) ──
	if (( full )); then
		local -a shown=()
		local result f seen2 s rel title2
		for result in "${results[@]}"; do
			f=$(echo "$result" | cut -d'|' -f1)
			seen2=false
			for s in "${shown[@]}"; do
				[[ "$s" == "$f" ]] && seen2=true && break
			done
			$seen2 && continue
			shown+=("$f")
			rel="${f#$BRAIN_DIR/}"
			title2=$(_brain_title "$f")
			echo
			echo "===== $rel ($title2) ====="
			cat "$f"
			echo
		done
		return 0
	fi

	local total=${#results[@]}
	log_info "Found $total match(es):"
	echo

	local -a menu_files=()
	local -a menu_titles=()
	local idx=0
	for result in "${results[@]}"; do
		local f=$(echo "$result" | cut -d'|' -f1)
		local ln=$(echo "$result" | cut -d'|' -f2)
		local text=$(echo "$result" | cut -d'|' -f3-)
		local relative="${f#$BRAIN_DIR/}"
		local title
		title=$(_brain_title "$f")

		# Only show unique files in menu
		local seen=false
		for mf in "${menu_files[@]}"; do
			[[ "$mf" == "$f" ]] && seen=true && break
		done
		if ! $seen; then
			menu_files+=("$f")
			menu_titles+=("$title")
			printf "    ${D_GREEN}%2d.${D_NC} ${D_CYAN}%s${D_NC}\n" $((idx + 1)) "$title"
			((idx++))
		fi
	done

	echo
	read_input "Open memory (# or name)" pick

	if [[ -z "$pick" ]]; then
		return 0
	fi

	local selected_file=""
	if [[ "$pick" =~ ^[0-9]+$ ]] && ((pick >= 1 && pick <= ${#menu_files[@]})); then
		selected_file="${menu_files[$((pick - 1))]}"
	else
		for i in "${!menu_titles[@]}"; do
			if echo "${menu_titles[$i]}" | grep -qi "$pick"; then
				selected_file="${menu_files[$i]}"
				break
			fi
		done
	fi

	if [[ -z "$selected_file" ]] || [[ ! -f "$selected_file" ]]; then
		log_error "Memory not found"
		return 1
	fi

	echo
	if command -v bat &>/dev/null; then
		bat "$selected_file"
	else
		cat "$selected_file"
	fi

	echo
}

# ── List ─────────────────────────────────────────────────────

brain_ls() {
	_brain_ensure || return 1

	local filter="$*"

	separator
	box_large "Your Memories"
	separator
	echo

	local total=0
	local dirs

	if [[ -n "$filter" ]]; then
		dirs="$BRAIN_DIR/$filter"
		if [[ ! -d "$dirs" ]]; then
			log_warn "Category not found: $filter"
			return 1
		fi
	else
		dirs=$(find "$BRAIN_DIR" -mindepth 1 -maxdepth 1 -type d ! -name ".git" 2>/dev/null | sort)
		if [[ -z "$dirs" ]]; then
			echo -e "    ${D_GRAY}No memories yet${D_NC}"
			echo
			list_item "Add one: ${D_CYAN}core brain save${D_NC}"
			return 0
		fi
	fi

	while IFS= read -r dir; do
		local category
		category=$(basename "$dir")
		local files
		files=$(find "$dir" -maxdepth 1 -name "*.md" ! -name "README.md" 2>/dev/null | sort -r)

		if [[ -z "$files" ]]; then
			continue
		fi

		if [[ -z "$filter" ]]; then
			echo
			separator_section "$category"
			echo
		fi

		while IFS= read -r file; do
			local title
			title=$(_brain_title "$file")
			local tags_line
			tags_line=$(grep "^tags:" "$file" 2>/dev/null | sed 's/tags: \[//;s/\]//;s/, /, /g')
			printf "    ${D_GREEN}•${D_NC} %s\n" "$title"
			if [[ -n "$tags_line" ]]; then
				printf "      ${D_DIM}%s${D_NC}\n" "$tags_line"
			fi
			((total++))
		done <<<"$files"
	done <<<"$dirs"

	echo
	separator
	list_item "$total memory(ies)"
	separator
}

# ── Relate ──────────────────────────────────────────────────

brain_relate() {
	_brain_ensure || return 1

	local slug_a="$1"
	local slug_b="$2"
	local file_a="" file_b=""

	if [[ -z "$slug_a" ]] || [[ -z "$slug_b" ]]; then
		separator
		box_large "Relate Memories"
		separator
		echo
		log_info "Pick the first memory:"
		echo
		file_a=$(_brain_pick_file "First memory (# or name)")
		[[ -z "$file_a" ]] && return 0

		echo
		log_info "Pick the second memory:"
		echo
		file_b=$(_brain_pick_file "Second memory (# or name)")
		[[ -z "$file_b" ]] && return 0
	else
		file_a=$(find "$BRAIN_DIR" -name "${slug_a}.md" 2>/dev/null | head -1)
		file_b=$(find "$BRAIN_DIR" -name "${slug_b}.md" 2>/dev/null | head -1)

		if [[ -z "$file_a" ]]; then
			log_error "Memory not found: $slug_a"
			return 1
		fi
		if [[ -z "$file_b" ]]; then
			log_error "Memory not found: $slug_b"
			return 1
		fi
	fi

	echo
	slug_a=$(basename "$file_a" .md)
	slug_b=$(basename "$file_b" .md)

	_brain_update_related "$file_a" "$slug_b"
	_brain_update_related "$file_b" "$slug_a"

	log_success "Linked ${D_CYAN}$(_brain_title "$file_a")${D_NC} ↔ ${D_CYAN}$(_brain_title "$file_b")${D_NC}"
	echo
}

# ── Show ─────────────────────────────────────────────────────

_brain_show_relations() {
	local file="$1"
	local related
	related=$(grep "^related:" "$file" 2>/dev/null | sed 's/related: \[//;s/\]//')
	[[ -z "$related" ]] && return

	echo -e "    ${D_GRAY}──${D_NC} ${GRAY}Related${NC}"
	local IFS=','
	for r in $related; do
		r=$(echo "$r" | xargs)
		[[ -z "$r" ]] && continue
		local rfile
		rfile=$(find "$BRAIN_DIR" -name "${r}.md" 2>/dev/null | head -1)
		if [[ -n "$rfile" ]]; then
			local rtitle
			rtitle=$(_brain_title "$rfile")
			printf "    ${D_GREEN}•${D_NC} %s\n" "$rtitle"
		fi
	done
	IFS=$' \t\n'
}

brain_show() {
	_brain_ensure || return 1

	local slug="$1"
	local file=""

	if [[ -n "$slug" ]]; then
		file=$(find "$BRAIN_DIR" -name "${slug}.md" 2>/dev/null | head -1)
		if [[ -z "$file" ]]; then
			log_error "Memory not found: $slug"
			return 1
		fi
	else
		echo
		separator_section "Show Memory"
		echo
		file=$(_brain_pick_file "Memory to show (# or name)")
		[[ -z "$file" ]] && return 0
	fi

	echo
	if command -v bat &>/dev/null; then
		bat "$file"
	else
		cat "$file"
	fi

	_brain_show_relations "$file"
	echo
}

# ── Graph ────────────────────────────────────────────────────

brain_graph() {
	_brain_ensure || return 1

	# ── --json: machine-readable graph for the AI agent ──
	local json=0
	[[ "$1" == "--json" ]] && json=1

	echo
	separator_section "Knowledge Graph"
	echo

	local -a files=()
	while IFS= read -r f; do
		files+=("$f")
	done < <(find "$BRAIN_DIR" -name "*.md" ! -name "README.md" 2>/dev/null | sort)

	if [[ ${#files[@]} -eq 0 ]]; then
		if (( json )); then
			echo '{"memories":[]}'
		fi
		list_item "No memories yet"
		return 0
	fi

	if (( json )); then
		local -a nodes=()
		local f
		for f in "${files[@]}"; do
			local jtitle jslug jcat jtags jrel
			jtitle=$(_brain_title "$f")
			jslug=$(basename "$f" .md)
			jcat=$(basename "$(dirname "$f")")
			jtags=$(grep "^tags:" "$f" 2>/dev/null | sed 's/^tags: \[//;s/\]//')
			jrel=$(grep "^related:" "$f" 2>/dev/null | sed 's/^related: \[//;s/\]//')
			nodes+=("$(jq -nc \
				--arg s "$jslug" --arg t "$jtitle" --arg c "$jcat" \
				--arg tg "$jtags" --arg r "$jrel" \
				'{slug:$s, title:$t, category:$c, tags:(if $tg=="" then [] else ($tg | split(", ")) end), related:(if $r=="" then [] else ($r | split(", ")) end)}' 2>/dev/null)")
		done
		local json_list=""
		if [[ ${#nodes[@]} -gt 0 ]]; then
			json_list=$(IFS=,; echo "${nodes[*]}")
		fi
		jq -nc --argjson nodes "[$json_list]" '{memories:$nodes}'
		return 0
	fi

	local total_edges=0
	for f in "${files[@]}"; do
		local title
		title=$(_brain_title "$f")
		local slug
		slug=$(basename "$f" .md)
		local category
		category=$(basename "$(dirname "$f")")
		local related
		related=$(grep "^related:" "$f" 2>/dev/null | sed 's/related: \[//;s/\]//')

		printf "    ${D_CYAN}%s${NC} ${D_DIM}(%s)${D_NC}\n" "$title" "$category"

		if [[ -n "$related" ]]; then
			local IFS=','
			for r in $related; do
				r=$(echo "$r" | xargs)
				[[ -z "$r" ]] && continue
				local rfile
				rfile=$(find "$BRAIN_DIR" -name "${r}.md" 2>/dev/null | head -1)
				if [[ -n "$rfile" ]]; then
					local rtitle
					rtitle=$(_brain_title "$rfile")
					local rcat
					rcat=$(basename "$(dirname "$rfile")")
					printf "    ${GRAY}└──${NC} %s ${D_DIM}(%s)${D_NC}\n" "$rtitle" "$rcat"
					((total_edges++))
				fi
			done
			IFS=$' \t\n'
		else
			printf "    ${GRAY}└──${NC} ${D_DIM}(no relations)${D_NC}\n"
		fi
		echo
	done

	list_item "$total_edges connections across ${#files[@]} memories"
	echo
}

# ── Sync ────────────────────────────────────────────────────

brain_sync() {
	_brain_ensure || return 1

	separator
	box_large "Sync Brain"
	separator
	echo

	if [[ ! -d "$BRAIN_DIR/.git" ]]; then
		log_warn "Not a git repository"
		list_item "Run: ${D_CYAN}core brain init${D_NC} to set up Git"
		separator
		return 1
	fi

	cd "$BRAIN_DIR" || return 1

	if ! git remote -v &>/dev/null; then
		log_info "No remote configured — local commit only"
		list_item "Set up GitHub sync with: ${D_CYAN}core brain init${D_NC}"
		separator
		return 0
	fi

	local commit_msg="brain sync $(date +%Y-%m-%d_%H:%M)"
	if [[ -n "$(git status --porcelain)" ]]; then
		loading "Staging changes..." git add -A
		loading "Committing changes..." git commit -m "$commit_msg"
	else
		log_info "No changes to commit"
	fi

	local branch
	branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

	if ! git rev-parse --abbrev-ref --symbolic-full-name @{upstream} &>/dev/null; then
		loading "Pushing to origin/$branch..." git push -u origin "$branch"
		if [[ $? -eq 0 ]]; then
			log_success "Brain synced with GitHub"
		else
			log_error "Push failed"
			list_item "Check your GitHub authentication: ${D_CYAN}gh auth login${D_NC}"
		fi
		separator
		return
	fi

	loading "Pulling latest from remote..." git pull --rebase
	local pull_exit=$?
	if [[ $pull_exit -ne 0 ]]; then
		log_error "Pull failed — your local and remote histories diverged"
		list_item "Force push instead: ${D_CYAN}git push --force${D_NC}"
		list_item "Or resolve manually in: ${D_CYAN}$BRAIN_DIR${D_NC}"
		separator
		return 1
	fi

	loading "Pushing to remote..." git push
	if [[ $? -eq 0 ]]; then
		log_success "Brain synced with GitHub"
	else
		log_error "Push failed"
		list_item "Check your connection and permissions"
	fi

	separator
}

# ── Skill ───────────────────────────────────────────────────

# Expands the given selected files with their related memories.
# Fills the global BRAIN_SKILL_EXPANDED array.
_brain_expand_selected() {
	BRAIN_SKILL_EXPANDED=()
	local -a seen=()
	local f slug dup s related r rf rdup
	for f in "$@"; do
		slug=$(basename "$f" .md)
		dup=false
		for s in "${seen[@]}"; do
			[[ "$s" == "$slug" ]] && dup=true && break
		done
		$dup && continue
		seen+=("$slug")
		BRAIN_SKILL_EXPANDED+=("$f")

		related=$(grep "^related:" "$f" 2>/dev/null | sed 's/related: \[//;s/\]//')
		if [[ -n "$related" ]]; then
			local IFS=','
			for r in $related; do
				r=$(echo "$r" | xargs)
				[[ -z "$r" ]] && continue
				rdup=false
				for s in "${seen[@]}"; do
					[[ "$s" == "$r" ]] && rdup=true && break
				done
				$rdup && continue
				seen+=("$r")
				rf=$(find "$BRAIN_DIR" -name "${r}.md" 2>/dev/null | head -1)
				[[ -n "$rf" ]] && BRAIN_SKILL_EXPANDED+=("$rf")
			done
			IFS=$' \t\n'
		fi
	done
}

brain_skill() {
	_brain_ensure || return 1

	# ── Non-interactive flags (AI agent mode) ──
	local skill_name="" base_dir="" all=0
	while [[ $# -gt 0 ]]; do
		case "$1" in
		--name) skill_name="$2"; shift 2 ;;
		--all) all=1; shift ;;
		--global) base_dir="$HOME/.agents/skills"; shift ;;
		*) shift ;;
		esac
	done

	# ── Collect all memories ──
	local -a all_files=()
	while IFS= read -r f; do
		all_files+=("$f")
	done < <(find "$BRAIN_DIR" -name "*.md" ! -name "README.md" 2>/dev/null | sort)

	if [[ ${#all_files[@]} -eq 0 ]]; then
		echo
		separator
		box_large "Create Skill from Memories"
		separator
		echo
		list_item "No memories yet"
		list_item "Create some: ${D_CYAN}core brain save${D_NC}"
		separator
		return 0
	fi

	# ── Pick memories (multi-select) ──
	local -a selected=() expanded=()
	if (( all )); then
		selected=("${all_files[@]}")
	else
		while true; do
			echo
			separator
			box_large "Create Skill from Memories"
			separator
			echo

			local idx=0
			for f in "${all_files[@]}"; do
				local t
				t=$(_brain_title "$f")
				printf "    ${D_GREEN}%2d.${D_NC} %s\n" $((idx + 1)) "$t"
				((idx++))
			done

			echo
			log_info "Select memories to include in the skill"
			read_input "Numbers (comma-separated), 'all', or empty to cancel" pick

			if [[ -z "$pick" ]]; then
				return 0
			fi

			selected=()
			if [[ "$pick" == "all" ]]; then
				for ((i = 0; i < ${#all_files[@]}; i++)); do
					selected+=("${all_files[$i]}")
				done
			else
				local IFS=','
				for num in $pick; do
					num=$(echo "$num" | xargs)
					if [[ "$num" =~ ^[0-9]+$ ]] && ((num >= 1 && num <= ${#all_files[@]})); then
						selected+=("${all_files[$((num - 1))]}")
					fi
				done
				IFS=$' \t\n'
			fi

			_brain_expand_selected "${selected[@]}"
			expanded=("${BRAIN_SKILL_EXPANDED[@]}")

			echo
			log_info "Skill will include ${#expanded[@]} memories:"
			for f in "${expanded[@]}"; do
				local et
				et=$(_brain_title "$f")
				echo -e "    ${D_GREEN}•${D_NC} $et"
			done
			echo
			read_confirm "Proceed?" confirm
			[[ "$confirm" == "y" ]] && break
		done
	fi

	# ── Expand relations (--all path) ──
	if (( all )); then
		_brain_expand_selected "${selected[@]}"
		expanded=("${BRAIN_SKILL_EXPANDED[@]}")
	fi

	# ── Skill name ──
	if [[ -z "$skill_name" ]]; then
		read_input "Skill name (kebab-case, e.g. react-hooks)" skill_name
	fi
	skill_name=$(echo "$skill_name" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-+|-+$//g')
	if [[ -z "$skill_name" ]]; then
		log_error "Skill name cannot be empty"
		separator
		return 1
	fi

	# ── Global or local ──
	if [[ -z "$base_dir" ]]; then
		echo
		log_info "Where do you want to install the skill?"
		read_confirm "Install globally (~/.agents/skills/)?" scope
		if [[ "$scope" == "y" ]]; then
			base_dir="$HOME/.agents/skills"
		else
			base_dir=".agents/skills"
		fi
	fi

	local skill_dir="$base_dir/$skill_name"
	if [[ -d "$skill_dir" ]]; then
		if (( all )); then
			rm -rf "$skill_dir"
		else
			log_warn "Skill already exists: $skill_dir"
			read_confirm "Overwrite?" confirm
			[[ "$confirm" != "y" ]] && return 0
			rm -rf "$skill_dir"
		fi
	fi

	mkdir -p "$skill_dir/memories"
	log_success "Creating skill: ${D_CYAN}$skill_name${D_NC}"

	# ── Generate SKILL.md ──
	local description="Skill generated from brain memories"
	local trigger="Use when the user asks about: "
	local first=true
	for f in "${expanded[@]}"; do
		local ft
		ft=$(_brain_title "$f")
		if $first; then
			trigger+="$ft"
			first=false
		else
			trigger+=", $ft"
		fi
	done

	{
		echo "---"
		echo "name: $skill_name"
		echo "description: $description"
		echo "trigger: $trigger"
		echo "---"
		echo
		echo "# $skill_name"
		echo
		echo "Skill created from the following brain memories:"
		echo
		for f in "${expanded[@]}"; do
			local ftag ftags
			ft=$(_brain_title "$f")
			ftags=$(grep "^tags:" "$f" 2>/dev/null | sed 's/tags: \[//;s/\]//')
			echo "## $ft"
			[[ -n "$ftags" ]] && echo "Tags: $ftags"
			echo
			# Include body after frontmatter
			local in_fm=false
			while IFS= read -r line; do
				if [[ "$line" == "---" ]]; then
					if $in_fm; then in_fm=false; continue; fi
					in_fm=true; continue
				fi
				$in_fm && continue
				echo "$line"
			done <"$f" | tail -n +2
			echo
			echo "---"
			echo
		done
	} >"$skill_dir/SKILL.md"

	# ── Link individual memory files ──
	local midx=1
	for f in "${expanded[@]}"; do
		local ft ftags frel
		ft=$(_brain_title "$f")
		ftags=$(grep "^tags:" "$f" 2>/dev/null | sed 's/tags: \[//;s/\]//')
		frel=$(grep "^related:" "$f" 2>/dev/null | sed 's/related: \[//;s/\]//')
		local fname
		fname=$(printf "%02d_%s.md" "$midx" "$(basename "$f" .md | sed 's/^[0-9-]*_//')")
		{
			echo "---"
			echo "title: $ft"
			[[ -n "$ftags" ]] && echo "tags: [$ftags]"
			[[ -n "$frel" ]] && echo "related: [$frel]"
			echo "---"
			echo
			# Copy body
			local in_fm=false
			while IFS= read -r line; do
				if [[ "$line" == "---" ]]; then
					if $in_fm; then in_fm=false; continue; fi
					in_fm=true; continue
				fi
				$in_fm && continue
				echo "$line"
			done <"$f"
		} >"$skill_dir/memories/$fname"
		((midx++))
	done

	log_success "Skill created: ${D_CYAN}$skill_dir${D_NC}"
	list_item "Your agent will load it automatically"
	separator
}

# ── Edit ─────────────────────────────────────────────────────

brain_edit() {
	_brain_ensure || return 1

	# ── flags: --content rewrites the body non-interactively ──
	local slug="" content=""
	while [[ $# -gt 0 ]]; do
		case "$1" in
		--content) content="$2"; shift 2 ;;
		*) [[ -z "$slug" ]] && slug="$1"; shift ;;
		esac
	done
	local file=""

	if [[ -n "$slug" ]]; then
		file=$(find "$BRAIN_DIR" -name "${slug}.md" 2>/dev/null | head -1)
		if [[ -z "$file" ]]; then
			log_error "Memory not found: $slug"
			return 1
		fi
	else
		echo
		separator_section "Edit Memory"
		echo
		file=$(_brain_pick_file "Memory to edit (# or name)")
	fi

	if [[ -z "$file" ]]; then
		return 0
	fi

	# ── Non-interactive body replacement ──
	if [[ -n "$content" ]]; then
		local fm_end
		fm_end=$(awk '/^---$/ {++n} n==2 {print NR; exit}' "$file")
		if [[ -n "$fm_end" ]]; then
			{
				head -n "$fm_end" "$file"
				echo
				echo "$content"
			} >"$file.new"
			mv "$file.new" "$file"
		else
			echo "$content" >>"$file"
		fi
		log_success "Memory updated: ${D_CYAN}$(_brain_title "$file")${D_NC}"
		echo
		return 0
	fi

	local editor="${EDITOR:-}"
	if command -v nvim &>/dev/null; then
		editor="nvim"
	elif [[ -z "$editor" ]] || ! command -v "$editor" &>/dev/null; then
		for e in vim nano vi; do
			if command -v "$e" &>/dev/null; then
				editor="$e"
				break
			fi
		done
	fi

	if [[ -z "$editor" ]]; then
		log_error "No editor found"
		list_item "Install one: ${D_CYAN}core install editor${D_NC}"
		return 1
	fi

	echo
	log_info "Opening: ${D_CYAN}$(_brain_title "$file")${D_NC}"

	"$editor" "$file"

	log_success "Memory updated"
	echo
}

# ── Delete ───────────────────────────────────────────────────

brain_delete() {
	_brain_ensure || return 1

	# ── flags: --yes skips the confirmation (AI agent mode) ──
	local slug="" yes=0
	while [[ $# -gt 0 ]]; do
		case "$1" in
		--yes) yes=1; shift ;;
		*) [[ -z "$slug" ]] && slug="$1"; shift ;;
		esac
	done
	local file=""

	if [[ -n "$slug" ]]; then
		file=$(find "$BRAIN_DIR" -name "${slug}.md" 2>/dev/null | head -1)
		if [[ -z "$file" ]]; then
			log_error "Memory not found: $slug"
			return 1
		fi
	else
		echo
		separator_section "Delete Memory"
		echo
		file=$(_brain_pick_file "Memory to delete (# or name)")
	fi

	if [[ -z "$file" ]]; then
		return 0
	fi

	local title
	title=$(_brain_title "$file")
	if [[ "$yes" != "1" ]]; then
		echo
		log_warn "Delete memory: ${D_CYAN}$title${D_NC}?"
		read_confirm "This cannot be undone" confirm
		if [[ "$confirm" != "y" ]]; then
			log_info "Cancelled"
			return 0
		fi
	fi

	# Remove relations from related files
	local file_slug
	file_slug=$(basename "$file" .md)
	while IFS= read -r rfile; do
		_brain_remove_related "$rfile" "$file_slug"
	done < <(rg -l "$file_slug" "$BRAIN_DIR" --glob '*.md' 2>/dev/null || true)

	rm "$file"
	log_success "Deleted: ${D_CYAN}$title${D_NC}"

	# Clean up empty category directory
	local dir
	dir=$(dirname "$file")
	if [[ -z "$(find "$dir" -name '*.md' ! -name 'README.md' 2>/dev/null)" ]]; then
		rmdir "$dir" 2>/dev/null || true
		list_item "Empty category directory removed"
	fi

	echo
}

# ── Reset ────────────────────────────────────────────────────

brain_reset() {
	separator
	box_large "Reset Brain"
	separator
	echo

	if [[ ! -d "$BRAIN_DIR" ]]; then
		log_warn "Brain does not exist"
		separator
		return 0
	fi

	log_warn "This will DESTROY all local memories:"
	list_item "Location: ${D_CYAN}$BRAIN_DIR${D_NC}"
	echo

	read_confirm "Are you sure?" confirm
	if [[ "$confirm" != "y" ]]; then
		log_info "Cancelled"
		separator
		return 0
	fi

	echo
	loading "Deleting local brain..." rm -rf "$BRAIN_DIR"
	log_success "Brain destroyed"
	list_item "Recreate with: ${D_CYAN}core brain init${D_NC}"
	separator
}

# ── Dashboard ────────────────────────────────────────────────

brain_dashboard() {
	if [[ ! -d "$BRAIN_DIR" ]]; then
		brain_help
		return
	fi

	echo
	separator_section "Core Brain Dashboard"
	echo

	local total_files
	total_files=$(find "$BRAIN_DIR" -name "*.md" ! -name "README.md" 2>/dev/null | wc -l)
	local total_categories
	total_categories=$(find "$BRAIN_DIR" -mindepth 1 -maxdepth 1 -type d ! -name ".git" 2>/dev/null | wc -l)
	local has_git=false
	[[ -d "$BRAIN_DIR/.git" ]] && has_git=true

	printf "    ${D_CYAN}%-20s${NC} ${GRAY}=${NC} %s\n" "Memories" "$total_files"
	printf "    ${D_CYAN}%-20s${NC} ${GRAY}=${NC} %s\n" "Categories" "$total_categories"
	printf "    ${D_CYAN}%-20s${NC} ${GRAY}=${NC} %s\n" "Git" "$($has_git && echo '✓' || echo '✗')"
	printf "    ${D_CYAN}%-20s${NC} ${GRAY}=${NC} ${D_DIM}%s${D_NC}\n" "Location" "$BRAIN_DIR"
	echo

	separator_section "Quick Start"
	echo
	list_item "Save: ${D_CYAN}core brain save${D_NC}"
	list_item "Show: ${D_CYAN}core brain show${D_NC}"
	list_item "Search: ${D_CYAN}core brain search${D_NC}"
	list_item "Edit: ${D_CYAN}core brain edit${D_NC}"
	list_item "Delete: ${D_CYAN}core brain delete${D_NC}"
	list_item "Reset: ${D_CYAN}core brain reset${D_NC}"
	list_item "Graph: ${D_CYAN}core brain graph${D_NC}"
	list_item "Skill: ${D_CYAN}core brain skill${D_NC}"
	list_item "Sync: ${D_CYAN}core brain sync${D_NC}"
	echo
}

# ── Main dispatcher ──────────────────────────────────────────

brain_main() {
	local cmd="$1"
	shift || true

	case "$cmd" in
	init)
		brain_init
		;;
	save)
		brain_save "$@"
		;;
	search)
		brain_search "$@"
		;;
	ls | list)
		brain_ls "$@"
		;;
	edit)
		brain_edit "$@"
		;;
	delete | rm)
		brain_delete "$@"
		;;
	reset | destroy)
		brain_reset
		;;
	relate)
		brain_relate "$@"
		;;
	show | view)
		brain_show "$@"
		;;
	graph | map)
		brain_graph "$@"
		;;
	skill | skills)
		brain_skill "$@"
		;;
	sync)
		brain_sync
		;;
	"" | --help | -h)
		brain_help
		;;
	*)
		log_error "Unknown subcommand: $cmd"
		echo
		brain_help
		exit 1
		;;
	esac
}
