#!/bin/sh

BL_SYS_DIR=/sys/class/backlight

show_help() {
	echo "Usage: brightness_control COMMAND <args>"
	echo "Commands:"
	echo "    step [+/-] STEP"
	echo "    get_percent"
	echo "    show_rules"
}

do_show_rules() {
	echo "Make sure to set udev rules to allow users of video group to control backlight:"
	echo "    /etc/udev/rules.d/90-backlight.rules"
	echo '    SUBSYSTEM=="backlight", ACTION=="add", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"'
}

do_get_percent() {
	BRIGHNESS=""

	for DEVICE in $(find ${BL_SYS_DIR} -not -path ${BL_SYS_DIR})
	do
		B="$(cat ${DEVICE}/brightness)"
		MB="$(cat ${DEVICE}/max_brightness)"

		BRIGHTNESS="${BRIGHTNESS} $(((100*B)/MB))"
	done

	echo "${BRIGHTNESS}"
}

do_step() {
	STEP=$1

	for DEVICE in $(find ${BL_SYS_DIR} -not -path ${BL_SYS_DIR})
	do
		B="$(cat ${DEVICE}/brightness)"
		MB="$(cat ${DEVICE}/max_brightness)"
		NB=$((B+STEP))

		if [ $NB -ge $MB ]
		then
			NB=$MB
		fi

		if [ $NB -le 0 ]
		then
			NB=0
		fi

		echo "$NB" > ${DEVICE}/brightness
	done
}

if [ $# -ge 0 ]
then
	#if [ $1 == '--help' ]
	#then
	#	show_help
	#	exit 1
	#fi

	#DEVICE=$1

	case $1 in
		"step")
			do_step $2
			break
			;;
		"get_percent")
			do_get_percent
			break
			;;
		"show_rules")
			do_show_rules
			break
			;;
		*)
			show_help
			;;
	esac
else
	show_help
fi