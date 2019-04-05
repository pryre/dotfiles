#!/bin/sh

if [ -e ~/Media ]
then
	ARG='--play-pause'

	if [ $# -eq 1 ]
	then
		ARG="--$1"
	fi

	deadbeef --play-pause
else
	ERROR_TIME=2000
	ERROR_IMG=~/.icons/la-capitaine-icon-theme/actions/symbolic/action-unavailable-symbolic.svg
	notify-send -t $ERROR_TIME -i $ERROR_IMG "Music directory could not be accessed"
fi
