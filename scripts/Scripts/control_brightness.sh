#!/bin/sh

BL_SYS_DIR=/sys/class/backlight
MSG_ID_FILE="$XDG_RUNTIME_DIR/notifications/brightness"

show_help() {
	echo "Usage: control_brightness COMMAND <args>"
	echo "Commands:"
	echo "    set VALUE [DEVICE]"
	echo "    step [+/-]STEP"
	echo "    get_percent [DEVICE]"
	echo "    set_percent PERCENT [DEVICE]"
	echo "    step_percent [+/-]STEP"
	echo "    show_rules"
}

do_show_rules() {
	echo "Make sure to set udev rules to allow users of video group to control backlight:"
	echo "    /etc/udev/rules.d/90-backlight.rules"
	echo '    SUBSYSTEM=="backlight", ACTION=="add", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"'
}

do_get_percent_single() {
	DEVICE=$1
	B=$(cat ${DEVICE}/brightness)
	MB=$(cat ${DEVICE}/max_brightness)
	BRIGHTNESS="${BRIGHTNESS} $(((100*B)/MB))"

	echo $BRIGHTNESS
}

do_get_percent() {
	DEVICE=$1

	if [ -z $DEVICE ]
	then
		# No deviceses specified
		BRIGHTNESSES=""

		for DEVICE in $(find ${BL_SYS_DIR} -not -path ${BL_SYS_DIR})
		do
			BRIGHTNESSES="$BRIGHTNESSES $(do_get_percent_single $DEVICE)"
		done

		echo $BRIGHTNESSES
	else
		# Single device specified
		echo $(do_get_percent_single $DEVICE)
	fi
}

do_set_single() {
	NB=$1
	DEVICE=$2
	MB=$(cat ${DEVICE}/max_brightness)

	if [ $NB -ge $MB ]
	then
		NB=$MB
	fi

	if [ $NB -le 0 ]
	then
		NB=0
	fi

	echo "$NB" > ${DEVICE}/brightness
}

do_set() {
	VALUE=$1
	DEVICE=$2

	if [ -z $DEVICE ]
	then
		# No deviceses specified
		for DEVICE in $(find ${BL_SYS_DIR} -not -path ${BL_SYS_DIR})
		do
			do_set_single $VALUE $DEVICE
		done
	else
		# Single device specified
		do_set_single $VALUE $DEVICE
	fi
}

do_set_percent_single() {
	NBP=$1
	DEVICE=$2

	MB=$(cat ${DEVICE}/max_brightness)
	NB=$((NBP*MB/100))
	do_set_single $NB $DEVICE
}

do_set_percent() {
	NBP=$1
	DEVICE=$2

	if [ -z $DEVICE ]
	then
		# No deviceses specified
		for DEVICE in $(find ${BL_SYS_DIR} -not -path ${BL_SYS_DIR})
		do
			do_set_percent_single $NB $DEVICE
		done
	else
		# Single device specified
		do_set_percent_single $NB $DEVICE
	fi
}

do_step() {
	STEP=$1

	for DEVICE in $(find ${BL_SYS_DIR} -not -path ${BL_SYS_DIR})
	do
		B=$(get_percent ${DEVICE})
		NB=$((B+STEP))

		do_set_single $NB $DEVICE
	done
}

do_step_percent() {
	STEP=$1

	for DEVICE in $(find ${BL_SYS_DIR} -not -path ${BL_SYS_DIR})
	do
		B=$(do_get_percent $DEVICE)
		NB=$((B+STEP))

		echo $B
		echo $NB
		do_set_percent $NB $DEVICE
	done
}

if [ $# -ge 0 ]
then
	case $1 in
		"step")
			do_step $2
			break
			;;
		"set")
			do_set $2 $3
			break
			;;
		"get_percent")
			do_get_percent $2 $3
			break
			;;
		"set_percent")
			do_set_percent $2 $3
			break
			;;
		"step_percent")
			do_step_percent $2
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
