#!/bin/sh

if [ -z $XDG_CONFIG_HOME ]
then
	XDG_CONFIG_HOME=$HOME/.config
fi

NBG="$HOME/.background"
BBG="$XDG_CONFIG_HOME/swaylock/blur_background.png"

RECALC=
if [ ! -e "$BBG" ]
then
	RECALC=1
	echo not there
else
	if [ "$(($(date -r "$NBG" +%s)-$(date -r "$BBG" +%s)))" -gt 0 ]
	then
		RECALC=1
		echo newer
	fi
fi

if [ "$RECALC" ]
then
	echo blurring
    # cp -L $NBG $BBG
	# convert "$NBG" -filter Gaussian -blur 0x4 "$BBG"
	# convert "$NBG" -scale 10% -scale 1000% "$BBG"
	# convert $BBG -scale 25%
	# convert $BBG -blur 0x8 $BBG
	#Then put back to 200% to get back to orginal size
	# convert $BBG -scale 2.5%
	convert "$NBG" -scale 25% -blur 0x2 -scale 400% "$BBG"
	# convert "$NBG" -scale 50% "$BBG"
	# convert $NBG -blur 0x8 $BBG
	# convert "$BBG" -scale 200% "$BBG"
fi

swaylock -i "$BBG" $@

