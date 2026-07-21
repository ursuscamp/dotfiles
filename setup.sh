#!/bin/bash

PACKAGES="helix wezterm alacritty kitty zellij xplr fish nvim tmux zsh aerospace ghostty lazygit"

REPO=~/Dev/dotfiles
DESTINATION=$HOME

SOURCE=$REPO/config
CONFIG=$DESTINATION/.config

echo "SOURCE:      $SOURCE"
echo "DESTINATION: $DESTINATION"
echo "CONFIG:      $CONFIG"

echo
echo "Generating symlinks..."
for package in $PACKAGES
do
  ln -s $SOURCE/$package $CONFIG
done

# Homebrew files
ln -s $SOURCE/.Brewfile $DESTINATION
ln -s $SOURCE/.Brewfile.lock.json $DESTINATION

# Other dotfiles
ln -s $SOURCE/.aider.conf.yml $DESTINATION

# Pi config (safe subpaths only)
PI_AGENT_SOURCE="$REPO/pi/agent"
PI_AGENT_DEST="$HOME/.pi/agent"

link_pi_directory() {
  local source="$1"
  local destination="$2"

  if [[ -L "$destination" && "$(readlink "$destination")" == "$source" ]]; then
    return
  fi

  if [[ -e "$destination" || -L "$destination" ]]; then
    rm -rf -- "$destination"
  fi

  ln -s "$source" "$destination"
}

echo "Linking Pi config (extensions, themes)..."
mkdir -p "$PI_AGENT_DEST"
link_pi_directory "$PI_AGENT_SOURCE/extensions" "$PI_AGENT_DEST/extensions"
link_pi_directory "$PI_AGENT_SOURCE/themes" "$PI_AGENT_DEST/themes"
echo "Pi config linked: $PI_AGENT_DEST/extensions, $PI_AGENT_DEST/themes"

# Setup tmux plugin manager
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Zsh boilerplace and setup

if ! grep -q ZDOTDIR ~/.zprofile
then
	echo "ZDOTDIR=\$HOME/.config/zsh" >> ~/.zshenv
	echo "ZDOTDIR set in .zshenv"
fi

if [[ ! -f "$HOME/.config/zsh/envrc" ]]; then
	touch $HOME/.config/zsh/envrc
	echo "Put any private environment variables in the file $HOME/.config/zsh/envrc"
fi
