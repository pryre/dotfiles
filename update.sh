#!/bin/sh

echo "Updating dotfiles:"
git fetch

if [ $? -eq 0 ];
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
else
    echo "Unable to fetch updates from the remote repository"
fi

