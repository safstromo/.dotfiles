#!/bin/sh

echo "Creating shell with git and stow"

nix-shell -p git stow

echo "Cloning dotfiles"

git clone https://github.com/safstromo/.dotfiles.git

echo "Stowing dotfiles"

.././stowConfig

echo "Copying hardware-configuration.nix"

cp /etc/nixos/hardware-configuration.nix .

echo "Copy boot.initrd.luks.devices. line info from configuration.nix"
echo "to continue and run 'sudo nixos-rebuild switch --flake .#nixlap'"

