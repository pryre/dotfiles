#!/bin/sh

show_help() {
	echo "Usage: screenshot-notify COMMAND"
	echo "Commands:"
	echo "    active"
	echo "    select"
	echo "    full"
}

# if [ $# -ne 1 ]
# then
# 	show_help
# fi

DNAME=$(date +'%Y-%m-%d-%H-%M-%S')
CPATH=${HOME}/Pictures/${DNAME}_capture.png
CAPTURED=0

case $1 in
	active)
		grim -g "$(swaymsg -t get_tree | jq -r '.. | (.nodes? // empty)[] | select(.focused==true) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')" "${CPATH}"
    	# grim -g "$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')"
		CAPTURED=1
		;;
	select)
		CAPTURED=1
		grim -g "$(slurp)" "${CPATH}"
		;;
	full)
		grim "${CPATH}"
		CAPTURED=1
		;;
	*)
		show_help
		;;
esac

if [ $CAPTURED -gt 0 ]
then
	notify-send.sh -i camera "Screenshot Captured" '~/Pictures/'$DNAME
fi

