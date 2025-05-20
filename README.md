
## Branches

### Main
Main stuff

### Nixos
Nixos config

Install:
1. Install nix with luks encryption

Add to config to enable flakes, add nvim, git, ghostty
```
nix.settings.experimental-features = [ "nix-command" "flakes" ];
programs.neovim = {
enable = true;
defaultEditor = true;
};

environment.systemPackages = with pkgs; [
ghostty
git
];
```
Rebuild
sudo nixos-rebuild switch

Open a shell with git and clone repo
```
nix-shell -p git ghostty nvim
git clone https://github.com/safstromo/.dotfiles.git
```

Copy hardware file
Copy disk info configuration.nix


Stow .dotfiles with script
```
./stowConfig
```

sudo nixos-rebuild switch --flake .#nixlap


