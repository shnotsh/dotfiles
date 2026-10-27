#!/usr/bin/env bash
# Copy the configuration in this repository into a home directory.
# Usage: ./install.sh [target-home]
# Files that would be overwritten are first backed up to
# <target-home>/.dotfiles-backup/<timestamp>/.

set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
target_home=${1:-"$HOME"}
source_home=/home/sh
backup_dir="$target_home/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

if pgrep -x noctalia >/dev/null && [[ $target_home == "$HOME" ]]; then
	printf 'Noctalia is running and may overwrite its restored settings on exit.\n'
	printf 'Stopping it; restart it with "noctalia --daemon" or log in again.\n'
	pkill -x noctalia || true
fi

mapfile -d '' files < <(
	cd "$repo_dir" && find .config .local .icons Pictures \
		.bash_logout .bash_profile .bashrc .zshrc -type f -print0
)

backed_up=0
for relative in "${files[@]}"; do
	source="$repo_dir/$relative"
	destination="$target_home/${relative#./}"
	if [[ -e $destination ]] && ! cmp -s "$source" "$destination"; then
		mkdir -p "$backup_dir/$(dirname -- "$relative")"
		cp -a "$destination" "$backup_dir/$relative"
		backed_up=$((backed_up + 1))
	fi
	mkdir -p "$(dirname -- "$destination")"
	cp -a "$source" "$destination"

	# Absolute paths in the configs point at the original home directory.
	if [[ $target_home != "$source_home" ]] && grep -Iq "$source_home" "$destination" 2>/dev/null; then
		sed -i "s|$source_home|$target_home|g" "$destination"
	fi
done

chmod +x "$target_home"/.local/bin/* 2>/dev/null || true
command -v fc-cache >/dev/null && fc-cache -f "$target_home/.local/share/fonts" >/dev/null
command -v update-desktop-database >/dev/null \
	&& update-desktop-database "$target_home/.local/share/applications" 2>/dev/null || true

printf 'Installed %d files into %s\n' "${#files[@]}" "$target_home"
((backed_up)) && printf 'Backed up %d changed files to %s\n' "$backed_up" "$backup_dir"
printf '%s\n' 'Review machine-specific monitor, GPU and profile settings before starting applications.'
