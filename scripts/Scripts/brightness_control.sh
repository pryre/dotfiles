#!/bin/sh

show_help() {
	echo "Usage: brightness_control DEVICE COMMAND"
	echo "Commands:"
	echo "    step [+/-] STEP"
	echo "    get_percent"
	echo "Make sure to set udev rules to allow users of video group to control backlight:"
	echo "    /etc/udev/rules.d/90-backlight.rules"
	echo '    SUBSYSTEM=="backlight", ACTION=="add", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"'
}

do_get_percent() {
	DEVICE=$1

	B="$(cat /sys/class/backlight/${DEVICE}/brightness)"
	MB="$(cat /sys/class/backlight/${DEVICE}/max_brightness)"

	echo "$(((100*B)/MB))"
}

do_step() {
	DEVICE=$1
	STEP=$2

	B="$(cat /sys/class/backlight/${DEVICE}/brightness)"
	MB="$(cat /sys/class/backlight/${DEVICE}/max_brightness)"
	NB=$((B+STEP))

	if [ $NB -ge $MB ]
	then
		NB=$MB
	fi

	if [ $NB -le 0 ]
	then
		NB=0
	fi

	echo "$NB" > /sys/class/backlight/${DEVICE}/brightness
}

if [ $# -ge 1 ]
then
	if [ $1 == '--help' ]
	then
		show_help
		exit 1
	fi

	DEVICE=$1

	case $2 in
		"step")
			do_step $DEVICE $3
			break
			;;
		"get_percent")
			do_get_percent $DEVICE
			break
			;;
		*)
			show_help
			;;
	esac
else
	show_help
fi