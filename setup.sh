#!/bin/bash

PACKAGES="helix wezterm alacritty kitty zellij xplr fish nvim mininvim"

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
