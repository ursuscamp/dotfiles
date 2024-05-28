#!/bin/bash

PACKAGES="helix wezterm alacritty kitty zellij xplr fish nvim tmux zsh"

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

# Setup tmux plugin manager
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

if ! grep -q ZDOTDIR ~/.zprofile
then
	echo "ZDOTDIR=\$HOME/.config/zsh" >> ~/.zprofile
	echo "ZDOTDIR set in .zprofile"
fi
