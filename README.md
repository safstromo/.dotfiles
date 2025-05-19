
## Branches

### Main
Main stuff

### Nixos
Nixos config

Install:
1. Install nix with luks encryption

Open a shell with git and clone repo
```
nix-shell -p git
git clone https://github.com/safstromo/.dotfiles.git
```

Copy hardware file
Copy disk into configuration.nix

Stow .dotfiles with script
```
./stowConfig
```

sudo nixos-rebuild switch --experimental-features "nix-command flakes" --flake .


