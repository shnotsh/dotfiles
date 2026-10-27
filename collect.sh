#!/usr/bin/env bash
# Refresh the repository from the current home directory.
# The repository layout mirrors $HOME. Anything private is either skipped or
# sanitized (see sanitize_noctalia_settings) before it lands here.

set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

copy_tree() {
	local relative=$1
	[[ -d "$HOME/$relative" ]] || { printf 'skip (missing): ~/%s\n' "$relative"; return; }
	rm -rf "${repo_dir:?}/$relative"
	mkdir -p "$repo_dir/$relative"
	# Backups and editor leftovers never belong in the repository.
	rsync -a --exclude '*.bak' --exclude '*.bak-*' --exclude '*.backup-*' \
		--exclude '*.before-*' --exclude '*~' \
		"$HOME/$relative/" "$repo_dir/$relative/"
}

copy_file() {
	local relative=$1
	[[ -e "$HOME/$relative" ]] || { printf 'skip (missing): ~/%s\n' "$relative"; return; }
	mkdir -p "$repo_dir/$(dirname -- "$relative")"
	cp -a "$HOME/$relative" "$repo_dir/$relative"
}

# --- Complete portable configuration trees ---------------------------------
for directory in \
	hypr noctalia qt5ct qt6ct kitty uwsm xsettingsd \
	btop fastfetch fish MangoHud; do
	copy_tree ".config/$directory"
done

# --- Selected files from applications that keep private state alongside ---
for file in \
	zed/settings.json zed/keymap.json zed/tasks.json \
	godot/editor_settings-4.7.tres \
	gtk-3.0/settings.ini gtk-3.0/gtk.css gtk-3.0/noctalia.css \
	gtk-4.0/gtk.css gtk-4.0/noctalia.css gtk-4.0/thumbnail.png \
	blender/5.2/config/userpref.blend \
	goverlay/goverlay.conf goverlay/blacklist.conf \
	micro/settings.json micro/bindings.json \
	vkBasalt/vkBasalt.conf vkSumi/vkSumi.conf \
	mimeapps.list dolphinrc kdeglobals pavucontrol.ini; do
	copy_file ".config/$file"
done

copy_tree .config/zed/themes
copy_tree .config/micro/colorschemes

# --- Noctalia runtime state --------------------------------------------------
# Settings changed in the GUI live in settings.toml, not ~/.config/noctalia.
noctalia_state=.local/state/noctalia
copy_file "$noctalia_state/settings.toml"
copy_file "$noctalia_state/community-palettes/Mine.json"
copy_tree "$noctalia_state/plugins/data/nomadcxx"

sanitize_noctalia_settings() {
	# Drop calendar account identities and per-device Bluetooth/USB aliases
	# (they contain hardware addresses and serials).
	python3 - "$1" <<'PY'
import re, sys
path = sys.argv[1]
text = open(path, encoding="utf-8").read()
def drop_table(header, text):
    # A table runs until the next blank line or the next table header.
    return re.sub(r'(?m)^[ \t]*\[' + header + r'\][ \t]*\n(?:[ \t]*[^\[\s].*\n)*\n?', "", text)
text = drop_table(r'calendar\.account\.[^\]]+', text)
text = drop_table(r'plugin_settings\."sh/device-battery"\.device_aliases', text)
if re.search(r'username|device_aliases|@\w+\.\w+', text):
    sys.exit(f"sanitize: private data still present in {path}")
open(path, "w", encoding="utf-8").write(text)
PY
}
sanitize_noctalia_settings "$repo_dir/$noctalia_state/settings.toml"

# --- Scripts, launchers, assets ---------------------------------------------
# sh-dashboard's wrapper, service and launcher come from its own installer.
for file in screen-record-toggle fix-keyring-login; do
	copy_file ".local/bin/$file"
done
copy_file .local/share/applications/steam-no-slr.desktop
copy_file .local/share/color-schemes/noctalia.colors
copy_file .local/share/color-schemes/dolphin-readable.colors
copy_file .local/share/fonts/IosevkaCustom-Regular.ttf
copy_file .icons/default/index.theme

# Icons referenced by the Noctalia bar and plugins.
for file in game_mode_off.svg game_mode_on.svg start-here-cachyos-min.svg graphics-card.svg; do
	copy_file "Pictures/Icons/$file"
done

# --- Package lists ------------------------------------------------------------
# The lists are curated by hand, so only report explicitly installed packages
# that none of them mention yet.
listed=$(grep -hvE '^\s*(#|$)' "$repo_dir"/packages/*.txt | sort -u)
unlisted=$(comm -23 <(pacman -Qqe | sort) <(printf '%s\n' "$listed"))
[[ -n $unlisted ]] && printf 'Installed but not in packages/*.txt:\n%s\n\n' "$unlisted"

printf 'Collected configuration into %s\n' "$repo_dir"
printf 'Review "git diff" for secrets before committing.\n'
