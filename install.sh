#!/usr/bin/env bash

# change src where this repo is located
src="$HOME/dev/dotfiles"
# default nixos configuration folder
dst="/etc/nixos"

# clear dst folder
sudo rm -rf "$dst"/*

# copy all files to dst
sudo cp /home/mhd/dev/dotfiles/* /etc/nixos -R

# apply nixos configuration 
sudo nixos-rebuild switch --flake '/etc/nixos#nixos' --show-trace
home-manager switch --flake '/etc/nixos#mhd' --show-trace
