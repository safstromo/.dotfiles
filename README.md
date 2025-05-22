
## Branches

### Main
Main stuff

### Nixos
Nixos config

Install:
1. Install nix with luks encryption

2. Create a shell with git and stow
```
nix-shell -p git stow
```
3. Clone dotfiles

git clone https://github.com/safstromo/.dotfiles.git

4. Run prepare_system.sh

5. Add to config to enable flakes
```
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```
6. Rebuild system to activate flakes
```
sudo nixos-rebuild switch
```
7. Copy boot.initrd.luks.devices. line info from configuration.nix
Edit grub settings if needed

8. Rebuild flake
```
sudo nixos-rebuild switch --flake .#nixlap
```

