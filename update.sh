#!/bin/sh

DO_STOW=

if [ $# -ge 1 ]
then
	if [ "$1" = '-f' ]
	then
		DO_STOW=1
	fi
fi

echo "Updating dotfiles..."
git fetch

if [ $? -eq 0 ]
then
	if [ $DO_STOW ] || [ "$(git branch -v | grep -E '\[behind [0-9]*\]')" ]
	then
		echo ""
    	OLD_DIRS=$(ls -d */ | tr -d '/')
		echo "Removing links for:"
		echo "$OLD_DIRS"
		stow -D $OLD_DIRS
		echo ""

		echo "Merging changes:"
		git merge
		git submodule update --init
		echo ""

		NEW_DIRS=$(ls -d */ | tr -d '/')
		echo "Adding links for:"
		echo "$NEW_DIRS"
		stow $NEW_DIRS

		git submodule update
		gtk-update-icon-cache ~/.icons/la-capitaine-icon-theme
	else
		echo "Dotfiles are up to date!"
	fi

	echo ""

	if [ "$(git status --porcelain --ignore-submodules)" ]
	then
		echo "Repository contains untracked changes, consider updating"
	fi
else
    echo "Unable to fetch updates from the remote repository"
fi
