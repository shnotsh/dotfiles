#!/usr/bin/env bash

set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}

copy_tree() {
	local relative=$1
	mkdir -p "$repo_dir/.config/$relative"
	cp -a "$config_home/$relative/." "$repo_dir/.config/$relative/"
}

copy_file() {
	local relative=$1
	mkdir -p "$repo_dir/.config/$(dirname -- "$relative")"
	cp -a "$config_home/$relative" "$repo_dir/.config/$relative"
}

# Complete portable configuration trees.
for directory in \
	hypr noctalia qt5ct qt6ct kitty uwsm xsettingsd \
	alacritty btop fastfetch fish MangoHud; do
	copy_tree "$directory"
done

# Selected files from applications that also keep generated or private state
# beside their preferences.
for file in \
	zed/settings.json zed/keymap.json zed/tasks.json \
	godot/editor_settings-4.7.tres \
	gtk-3.0/settings.ini gtk-3.0/gtk.css gtk-3.0/noctalia.css \
	gtk-4.0/gtk.css gtk-4.0/noctalia.css gtk-4.0/thumbnail.png \
	blender/5.2/config/userpref.blend \
	goverlay/goverlay.conf goverlay/blacklist.conf \
	gram/settings.jsonc gram/keymap.jsonc gram/tasks.jsonc \
	micro/settings.json \
	vkBasalt/vkBasalt.conf vkSumi/vkSumi.conf; do
	copy_file "$file"
done

copy_tree zed/themes
copy_tree gram/themes
copy_tree micro/colorschemes

# Zen profile data is particularly sensitive. Collect customization only.
zen_profile='js9nf94v.Default (release)'
copy_tree "zen/$zen_profile/chrome"
for file in user.js zen-keyboard-shortcuts.json zen-themes.json; do
	copy_file "zen/$zen_profile/$file"
done

for file in .bash_logout .bash_profile .bashrc .zshrc; do
	cp -a "$HOME/$file" "$repo_dir/$file"
done

printf 'Collected portable configuration into %s\n' "$repo_dir"
