#!/usr/bin/env bash

set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
target_home=${1:-"$HOME"}

mkdir -p "$target_home/.config"
cp -a "$repo_dir/.config/." "$target_home/.config/"

for file in .bash_logout .bash_profile .bashrc .zshrc; do
	cp -a "$repo_dir/$file" "$target_home/$file"
done

printf 'Installed configuration into %s\n' "$target_home"
printf '%s\n' 'Review machine-specific monitor, GPU, font, SDK, and profile paths before starting applications.'
