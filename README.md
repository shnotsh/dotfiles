# Dotfiles

Configuration for a CachyOS + Hyprland (Lua config) + Noctalia workstation.
The repository layout mirrors `$HOME`, so `.config/hypr/hyprland.lua` belongs at
`~/.config/hypr/hyprland.lua`.

## Restore a fresh install

```bash
git clone https://github.com/shnotsh/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

`bootstrap.sh` does the following:

1. Installs `paru` if it is missing, then the packages in `packages/`.
   Repository packages that don't exist on the new system, such as
   hardware-specific kernels or drivers, are skipped and listed.
2. Runs `install.sh` to copy every file into `$HOME`. Any file it replaces is
   backed up to `~/.dotfiles-backup/<timestamp>/`.
3. Clones the custom [device-battery](https://github.com/shnotsh/solaar-noctalia)
   Noctalia plugin into `~/Developer/solaar-noctalia`. Noctalia's settings
   register that path as a plugin source.
4. Clones and installs sh-dashboard (private; needs `gh auth login`).
5. Enables user services and downloads the wallpapers listed in `wallpapers.txt`.

It finishes by printing the few manual steps left. Options: `--no-packages`,
`--no-wallpapers`, `--no-dashboard`. Use `./install.sh` alone to copy only the
configuration.

## Refresh this repository

```bash
./collect.sh
git diff   # review before committing; this repository is public
```

## What is included

- **Hyprland**: `hyprland.lua` plus `config/*.lua` (binds, rules, per-app
  keyboard layout in `app_layouts.lua`), UWSM env, xdg-desktop-portal config
- **Noctalia**
  - `~/.config/noctalia`: base config and palettes
  - `~/.local/state/noctalia/settings.toml`: the live settings edited in the GUI
    (bar layout, widgets, enabled plugins and plugin sources, theme)
  - the `Mine` community palette and gamer-mode logos
  - bar icons in `~/Pictures/Icons`: CachyOS start button, gamer-mode on/off, GPU
- **Scripts** in `~/.local/bin`:
  - `screen-record-toggle` (Caps+J): select a region to record with
    gpu-screen-recorder; press again to stop and save an MP4 and a GIF to
    `~/Videos/Recordings`
  - `fix-keyring-login`: unlocks gnome-keyring at greetd login
- **Look**: Bibata-Modern-Ice cursor, Colloid-Dark icons (installed from the
  AUR), Iosevka Custom font, KDE color schemes, and the GTK/Qt/Kitty/Alacritty/btop
  themes Noctalia generates
- **Apps**: Zed, Gram, Godot, Blender, Zen (customizations only), Kitty,
  Alacritty, btop, fastfetch, Fish, Micro, opencode, MangoHud, Goverlay,
  vkBasalt, vkSumi, Dolphin, default applications (`mimeapps.list`)
- **Packages**
  - `packages/pacman.txt`: explicitly installed repository packages
  - `packages/aur.txt`: AUR packages
  - `packages/extra.txt`: runtime dependencies the configs and scripts need
    directly (slurp, ffmpeg, wl-clipboard, solaar, python-dbus, …)

## Not included

These are deliberately left out: secrets, credentials, browser profiles and
history, caches, clipboard and notification history, recent-file lists, and
application databases. `collect.sh` also sanitizes the Noctalia settings. It
removes calendar accounts and device-battery aliases, which contain Bluetooth
addresses and device serials.

## Machine-specific values

- Monitor names and modes (`config/monitors.lua`, `config/variables.lua`) and the
  NVIDIA environment (`config/environment.lua`)
- Absolute `/home/sh` paths. `install.sh` rewrites them when the target home
  directory is different.
- The Zen profile directory `js9nf94v.Default (release)`
