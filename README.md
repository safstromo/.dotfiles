
## Branches

### Main
Main stuff

### Nixos
Nixos config

Install:

Open a shell with git and clone repo
```
nix-shell -p git
git clone https://github.com/safstromo/.dotfiles.git
```

check disk name lsblk and edit disko.nix if needed.


Generate hardware config
```
nixos-generate-config --root /tmp/config --no-filesystems
```

Copy the nixfiles from dotfiles.
```
sudo cp * /tmp/config/etc/nixos
```

Move to tempdir
```
cd /tmp/config/etc/nixos
```


Partition filesystem
```
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode disko ./disko.nix
```

Install
```
sudo nix-install --flake .#nixlap
```

Reboot

Stow .dotfiles
