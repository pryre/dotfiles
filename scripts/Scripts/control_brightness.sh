#!/bin/sh

# BL_SYS_DIR=/sys/class/backlight
MSG_ID_FILE="$XDG_RUNTIME_DIR/notifications/brightness"

show_help() {
	echo "Usage: control_brightness COMMAND <args>"
	echo "Commands:"
	echo "    set VALUE [DEVICE]"
	echo "    step [+/-]STEP"
	echo "    get_percent [DEVICE]"
	echo "    set_percent PERCENT [DEVICE]"
	echo "    step_percent [+/-]STEP"
	# echo "    show_rules"
}

# do_show_rules() {
# 	echo "Make sure to set udev rules to allow users of video group to control backlight:"
# 	echo "    /etc/udev/rules.d/90-backlight.rules"
# 	echo '    SUBSYSTEM=="backlight", ACTION=="add", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"'
# }

# do_get_percent_raw() {
# 	DEVICE=$1
# 	B=$(cat ${DEVICE}/brightness)
# 	MB=$(cat ${DEVICE}/max_brightness)
# 	BRIGHTNESS="${BRIGHTNESS} $(((100*B)/MB))"

# 	echo $BRIGHTNESS
# }

# do_get_devices() {
# 	if [ -z $DEVICES ]
# 	then
#     	echo $(find ${BL_SYS_DIR} -not -path ${BL_SYS_DIR})
# 	else
# 		echo $DEVICES
# 	fi
# }

# do_get_percent() {
# 	for DEVICE in $(do_get_devices "$1")
# 	do
# 		echo "$(basename $DEVICE): $(do_get_percent_raw $DEVICE)%"
# 	done
# }

# do_set_single() {
# 	NB=$1
# 	DEVICE=$2
# 	MB=$(cat ${DEVICE}/max_brightness)

# 	if [ $NB -ge $MB ]
# 	then
# 		NB=$MB
# 	fi

# 	if [ $NB -le 0 ]
# 	then
# 		NB=0
# 	fi

# 	echo "$NB" > ${DEVICE}/brightness
# }

# do_set() {
# 	VALUE=$1
# 	DEVICE=$2

# 	if [ -z $DEVICE ]
# 	then
# 		# No deviceses specified
# 		for DEVICE in $(find ${BL_SYS_DIR} -not -path ${BL_SYS_DIR})
# 		do
# 			do_set_single $VALUE $DEVICE
# 		done
# 	else
# 		# Single device specified
# 		do_set_single $VALUE $DEVICE
# 	fi
# }

# do_set_percent_single() {
# 	NBP=$1
# 	DEVICE=$2

# 	MB=$(cat ${DEVICE}/max_brightness)
# 	NB=$((NBP*MB/100))
# 	do_set_single $NB $DEVICE
# }

# do_set_percent() {
# 	NBP=$1
# 	DEVICE=$2

# 	if [ -z $DEVICE ]
# 	then
# 		# No deviceses specified
# 		for DEVICE in $(find ${BL_SYS_DIR} -not -path ${BL_SYS_DIR})
# 		do
# 			do_set_percent_single $NBP $DEVICE
# 		done
# 	else
# 		# Single device specified
# 		do_set_percent_single $NBP $DEVICE
# 	fi
# }

# do_step() {
# 	STEP=$1

# 	for DEVICE in $(find ${BL_SYS_DIR} -not -path ${BL_SYS_DIR})
# 	do
# 		B=$(do_get_percent_raw ${DEVICE})
# 		NB=$((B+STEP))

# 		do_set_single $NB $DEVICE
# 	done
# }

# do_step_percent() {
# 	STEP=$1

# 	for DEVICE in $(find ${BL_SYS_DIR} -not -path ${BL_SYS_DIR})
# 	do
# 		B=$(do_get_percent_raw $DEVICE)
# 		NB=$((B+STEP))

# 		echo $B
# 		echo $NB
# 		do_set_percent $NB $DEVICE
# 	done
# }

send_notify() {
	VAL=$(light -G) # Needs to be converted to in later

	notify-send.sh  "Brightness: $VAL" \
					-t 2000 \
					-a "control_brightness" \
					-u low \
					-i display-brightness-symbolic \
					-h int:value:$(printf "%.0f\n" $VAL) \
					-R "$MSG_ID_FILE"
}

if [ $# -ge 0 ]
then
	case $1 in
		"step")
			# do_step $2
			send_notify
			break
			;;
		"set")
			# do_set $2 $3
			light -Sr $2
			send_notify
			break
			;;
		"get_percent")
			# do_get_percent $2
			echo $(light -G)
			break
			;;
		"set_percent")
			# do_set_percent $2 $3
			light -S $2
			send_notify
			break
			;;
		"increase_percent")
			# do_step_percent $2
			light -A $2
			send_notify
			break
			;;
		"decrease_percent")
			# do_step_percent $2
			light -U $2
			send_notify
			break
			;;
		"multiply_percent")
			# do_step_percent $2
			light -T $2
			send_notify
			break
			;;
		# "show_rules")
		# 	do_show_rules
		# 	break
		# 	;;
		*)
			show_help
			;;
	esac
else
	show_help
fi
