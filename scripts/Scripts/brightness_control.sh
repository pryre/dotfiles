#!/bin/bash

if [ $# -eq 2 ]
then
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

	echo "$B"
	echo "$NB"

	echo "$NB" > /sys/class/backlight/${DEVICE}/brightness
else
	echo "Usage: brightness_control DEVICE STEP"
	echo "Make sure to set udev rules to allow users of video group to control backlight:"
	echo "    /etc/udev/rules.d/90-backlight.rules"
	echo '    SUBSYSTEM=="backlight", ACTION=="add", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"'
fi