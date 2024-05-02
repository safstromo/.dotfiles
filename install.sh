#!/usr/bin/env zsh
 # Install script for dotfiles in codespaces
 #
 #
 #
 #
 #
 #
 # Install ripgrep, fzf, zsh, tmux, neovim, and stow
 #
 
 echo "Installing dotfiles"

 # Install ripgrep
 echo "Installing ripgrep"
 if ! command -v rg &> /dev/null
 then
     echo "Installing ripgrep"
     sudo apt-get install ripgrep
 fi

 # Install fzf
 echo "Installing fzf"
 if ! command -v fzf &> /dev/null
 then
     echo "Installing fzf"
     sudo apt-get install fzf
 fi

 # Install tmux
 echo "Installing tmux" 
 if ! command -v tmux &> /dev/null
 then
     echo "Installing tmux"
     sudo apt-get install tmux
 fi


 # Install nvim latest version
 echo "Installing neovim"
 if ! command -v nvim &> /dev/null
 then
     echo "Installing neovim"
     sudo apt-get install neovim
 fi

 echo "Installing zsh"
 # Install oh-my-zsh
 sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


 # Install fonts
 echo "Installing fonts"
 FONT_DIR="$HOME/.fonts"
 curl https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip -o JetBrainsMono.zip
 unzip JetBrainsMono.zip -d $FONT_DIR

 # Install spaceship prompt
 echo "Installing spaceship prompt" 
 git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
 ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"


 # Install stow
 echo "Installing stow"
 if ! command -v stow &> /dev/null
 then
     echo "Installing stow"
     sudo apt-get install stow
 fi




 # Stow the dotfiles
 echo "Stowing dotfiles"
if [[ -z $STOW_FOLDERS ]]; then
    STOW_FOLDERS="nvim,tmux,zsh,bin"
fi

if [[ -z $DOTFILES ]]; then
    DOTFILES=$HOME


DOTFILES=$(dirname "$(readlink -f "$0")")
fi

STOW_FOLDERS=$STOW_FOLDERS DOTFILES=$DOTFILES $DOTFILES/stowScript

# Install tpm
echo "Installing tpm"
git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
