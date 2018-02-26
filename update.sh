#!/bin/sh
OLD_DIRS=$(ls -d */ | tr -d '/')
echo "Removing links for:"
echo "$OLD_DIRS"
stow -D $OLD_DIRS

echo ""
echo "Updating dotfiles:"
git pull
echo ""

NEW_DIRS=$(ls -d */ | tr -d '/')
echo "Adding links for:"
echo "$NEW_DIRS"
stow $NEW_DIRS
