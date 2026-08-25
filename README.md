# Dotfiles

Home-relative configuration collected from this workstation. The repository
layout mirrors `$HOME`, so `.config/hypr/hyprland.lua` belongs at
`~/.config/hypr/hyprland.lua`.

## Included

- Hyprland, UWSM, and xsettingsd
- Noctalia and its generated GTK, Qt, Kitty, Alacritty, and btop themes
- Zed and Gram settings, keymaps, tasks, and custom themes
- Godot editor preferences and Blender preferences
- Zen Browser custom CSS, `user.js`, keyboard shortcuts, and theme selections
- GTK 3/4, Qt 5/6, Kitty, Alacritty, btop, fastfetch, Fish, and Micro
- MangoHud, Goverlay, vkBasalt, and vkSumi
- Bash and Zsh preferences

Private and high-churn state is intentionally absent: browser passwords,
cookies, history, bookmarks, sessions and sync databases; caches and logs;
recent-file lists; OBS credentials; and other application databases.

## Use

Refresh the repository from the current home directory:

```bash
./collect.sh
```

Restore into the current home directory, or pass another home directory as the
first argument:

```bash
./install.sh
./install.sh /path/to/home
```

The installer overwrites files represented in this repository but does not
delete unrelated files. Back up the destination first when restoring to a
different machine.

## Machine-specific values

Some captured settings intentionally describe this workstation and may need
editing elsewhere:

- Hyprland monitor names/modes and NVIDIA environment settings
- `/home/sh` paths in Godot, fastfetch, and Qt configuration
- the Zen profile directory `js9nf94v.Default (release)`
- installed fonts, themes, applications, SDKs, and shell packages
