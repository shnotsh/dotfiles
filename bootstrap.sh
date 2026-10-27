#!/usr/bin/env bash
# Restore this workstation on a fresh CachyOS/Arch install:
# packages -> dotfiles -> custom Noctalia plugin -> services -> wallpapers.
# Usage: ./bootstrap.sh [--no-packages] [--no-wallpapers] [--no-dashboard]

set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
developer_dir="$HOME/Developer"
install_packages=1 fetch_wallpapers=1 install_dashboard=1

for argument in "$@"; do
	case $argument in
		--no-packages) install_packages=0 ;;
		--no-wallpapers) fetch_wallpapers=0 ;;
		--no-dashboard) install_dashboard=0 ;;
		-h | --help) sed -n '2,4p' "$0"; exit 0 ;;
		*) printf 'Unknown option: %s\n' "$argument" >&2; exit 2 ;;
	esac
done

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
read_list() { grep -vE '^\s*(#|$)' "$@" | sort -u; }

# --- Packages -----------------------------------------------------------------
if ((install_packages)); then
	step 'Installing packages'
	if ! command -v paru >/dev/null; then
		sudo pacman -S --needed --noconfirm base-devel git
		build_dir=$(mktemp -d)
		git clone --depth 1 https://aur.archlinux.org/paru-bin.git "$build_dir/paru-bin"
		(cd "$build_dir/paru-bin" && makepkg -si --noconfirm)
		rm -rf "$build_dir"
	fi
	sudo pacman -Syu --noconfirm

	# Skip repository packages that do not exist here (hardware-specific
	# kernels and drivers, or a non-CachyOS base) instead of failing outright.
	available=$(mktemp)
	pacman -Slq | sort -u >"$available"
	repo_packages=$(comm -12 <(read_list "$repo_dir/packages/pacman.txt" "$repo_dir/packages/extra.txt") "$available")
	missing=$(comm -23 <(read_list "$repo_dir/packages/pacman.txt") "$available" \
		| comm -23 - <(read_list "$repo_dir/packages/aur.txt"))
	aur_packages=$(comm -23 <(read_list "$repo_dir/packages/aur.txt" "$repo_dir/packages/extra.txt") "$available")
	rm -f "$available"

	# shellcheck disable=SC2086 # word splitting is intended
	sudo pacman -S --needed --noconfirm $repo_packages
	# shellcheck disable=SC2086
	[[ -n $aur_packages ]] && paru -S --needed --noconfirm $aur_packages
	[[ -n $missing ]] && printf 'Not available in the configured repositories, skipped:\n%s\n' "$missing"
fi

# --- Dotfiles -------------------------------------------------------------------
step 'Installing dotfiles'
"$repo_dir/install.sh"
mkdir -p "$HOME/Videos/Recordings" "$HOME/Pictures/Wallpapers"

# --- Noctalia: custom device-battery plugin ---------------------------------------
# settings.toml registers ~/Developer/solaar-noctalia as a path plugin source.
step 'Fetching the device-battery Noctalia plugin'
mkdir -p "$developer_dir"
if [[ -d "$developer_dir/solaar-noctalia/.git" ]]; then
	git -C "$developer_dir/solaar-noctalia" pull --ff-only
else
	git clone https://github.com/shnotsh/solaar-noctalia.git "$developer_dir/solaar-noctalia"
fi

# --- sh-dashboard (private repository) ----------------------------------------------
if ((install_dashboard)); then
	step 'Installing sh-dashboard'
	dashboard="$developer_dir/sh-dashboard"
	if [[ ! -d $dashboard/.git ]]; then
		if gh auth status >/dev/null 2>&1; then
			gh repo clone shnotsh/sh-dashboard "$dashboard"
		else
			printf 'Skipped: run "gh auth login", then re-run with --no-packages.\n'
		fi
	fi
	if [[ -d $dashboard/.git ]]; then
		(cd "$dashboard" && bash scripts/setup.sh && .venv/bin/sh-dashboard install --enable-limits)
	fi
fi

# --- Services -------------------------------------------------------------------
step 'Enabling user services'
systemctl --user enable psd.service 2>/dev/null || printf 'psd is not installed; skipped.\n'

# --- Wallpapers -----------------------------------------------------------------
if ((fetch_wallpapers)); then
	step 'Downloading wallpapers from wallhaven'
	while read -r name; do
		[[ -z $name || -e $HOME/Pictures/Wallpapers/$name ]] && continue
		id=${name#wallhaven-}; id=${id%.*}
		curl -fsSL --retry 2 -o "$HOME/Pictures/Wallpapers/$name" \
			"https://w.wallhaven.cc/full/${id:0:2}/$name" \
			|| printf 'Could not download %s\n' "$name"
	done <"$repo_dir/wallpapers.txt"
fi

step 'Done. Remaining manual steps'
cat <<'EOF'
 1. Log out and back in to Hyprland (UWSM session), so Noctalia starts with the
    restored settings.
 2. Fetch the community and official Noctalia plugins:
        noctalia msg plugins update
    If device-battery is not listed, run:
        python3 ~/Developer/solaar-noctalia/scripts/install.py
 3. Re-link the 8BitDo Bluetooth and USB entries in the device-battery widget
    (aliases contain hardware addresses, so they are not in the repo).
 4. Add the iCloud calendar account again in Noctalia settings.
 5. Optional: unlock the keyring on login with ~/.local/bin/fix-keyring-login
 6. sh-dashboard: load dist/extension in Helium (see that repo's README).
EOF
