#!/bin/sh

echo "Updating dotfiles..."
git fetch

if [ $? -eq 0 ]
then
	if [ "$(git branch -v | grep -E '\[behind [0-9]*\]')" ]
	then
		echo ""
    	OLD_DIRS=$(ls -d */ | tr -d '/')
		echo "Removing links for:"
		echo "$OLD_DIRS"
		stow -D $OLD_DIRS
		echo ""

		echo "Merging changes:"
		git merge
		echo ""

		NEW_DIRS=$(ls -d */ | tr -d '/')
		echo "Adding links for:"
		echo "$NEW_DIRS"
		stow $NEW_DIRS

		gtk-update-icon-cache ~/.icons/la-capitaine-icon-theme
	else
		echo "Dotfiles are up to date!"
	fi

	if [ "$(git status --porcelain --ignore-submodules)" ]
	then
		echo "Repository contains untracked changes, consider updating"
	fi
else
    echo "Unable to fetch updates from the remote repository"
fi
