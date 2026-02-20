#!/usr/bin/env bash

# change src where this repo is located
src="$HOME/dev/dotfiles"
# default nixos configuration folder
dst="/etc/nixos"

# remove existing destination if it exists
if [ -e "$dst" ]; then
    sudo rm -rf "$dst"
fi

# create symbolic link from src to dst
sudo ln -s "$src" "$dst"

# apply nixos configuration using the real path (home-manager is applied automatically as a NixOS module)
sudo nixos-rebuild switch --flake "$src#nixos" --show-trace