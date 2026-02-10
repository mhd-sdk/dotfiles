#!/usr/bin/env bash

# change src where this repo is located
src="$HOME/dev/dotfiles"
# default nixos configuration folder
dst="/etc/nixos"

# copy all files to dst
sudo cp -r "$src"/* "$dst"/

# apply nixos configuration (home-manager is applied automatically as a NixOS module)
sudo nixos-rebuild switch --flake '/etc/nixos#nixos' --show-trace
