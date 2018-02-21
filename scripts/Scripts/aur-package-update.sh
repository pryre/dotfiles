#!/bin/sh



if [ ! -z "$1" -a "$1" != " " ]; then
	makepkg --printsrcinfo > .SRCINFO
	git add PKGBUILD .SRCINFO
	git commit -m "$1"
	git push
else
	echo "Please include a commit message!"
fi
