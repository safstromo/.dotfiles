
## Branches

### Main
Main stuff

### Nixos
Nixos config

Install:
1. Install nix with luks encryption

2. Run prepare_system.sh

3. Add to config to enable flakes
```
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```
4. Rebuild system to activate flakes
```
sudo nixos-rebuild switch
```
5. Copy boot.initrd.luks.devices. line info from configuration.nix
Edit grub settings if needed

6. Rebuild flake
```
sudo nixos-rebuild switch --flake .#nixlap
```



#####
Open a shell with git and clone repo
```
nix-shell -p git 
git clone https://github.com/safstromo/.dotfiles.git

Add to config to enable flakes, add nvim, git, ghostty
```
nix.settings.experimental-features = [ "nix-command" "flakes" ];
programs.neovim = {
enable = true;
defaultEditor = true;
};

environment.systemPackages = with pkgs; [
ghostty
stow
git
];

Rebuild
```
sudo nixos-rebuild switch

```
Copy hardware file to .dotfiles/nixos
```
cd .dotfiles
cp /etc/nixos/hardware-configuration.nix .
```
#####
Copy boot.initrd.luks.devices. line info from configuration.nix
Edit grub settings if needed

Stow .dotfiles with script
```
./stowConfig
```

sudo nixos-rebuild switch --flake .#nixlap


