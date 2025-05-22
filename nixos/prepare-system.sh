#!/bin/sh

echo "Stowing dotfiles"

.././stowConfig

echo "Copying hardware-configuration.nix"

cp /etc/nixos/hardware-configuration.nix .

echo "Copy boot.initrd.luks.devices. line info from configuration.nix"
echo "to continue and run 'sudo nixos-rebuild switch --flake .#nixlap'"

