#!/bin/sh

if [ -z $XDG_CACHE_HOME ]
then
	XDG_CACHE_HOME=$HOME/.cache
fi

NBG="$HOME/.background"
BBG="$XDG_CACHE_HOME/swaylock/blur_background.png"

RECALC=
if [ ! -e "$BBG" ]
then
	RECALC=1
	mkdir -p $(dirname $BBG) # Make sure the directory exists
else
	# Does exist, but we need a newer copy
	if [ "$(($(date -r "$NBG" +%s)-$(date -r "$BBG" +%s)))" -gt 0 ]
	then
		RECALC=1
	fi
fi

if [ "$RECALC" ]
then
	# Many different options for performing the function
	# Scaling is used to speed up locking process
	#
    # cp -L $NBG $BBG
	# grim "$BBG"; convert "$BBG" -scale 10% -scale 1000% "$BBG" # Should be done per output
    # convert "$NBG" -filter Gaussian -blur 0x4 "$BBG"
	# convert "$NBG" -scale 10% -scale 1000% "$BBG"

	convert "$NBG" -scale 25% -blur 0x2 -scale 400% "$BBG"
fi

swaylock -i "$BBG" $@

