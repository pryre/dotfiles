#!/bin/sh

COMMAND=$1
SINKS=""
if [ $# -ge 2 ]
then
	if [ $2 = '-a' ]
	then
		# Use all sinks if flagged
		SINKS=$(pacmd list-sinks | tr \* ' ' | awk '/index:/{print $2}')
	else
		# Use list of sinks if provided
		shift
		SINKS="$@"
	fi
else
	# Grab first running sink if we have one
	RUNSINK=$(pacmd list-sinks | grep -e index -e state | sed -n '/RUNNING/{x;p;d;}; x' | head -n 1 | cut -d':' -f2)
	if [ -z "$RUNSINK" ]
	then
		# No match, use default sink if none provided
		SINKS=$(pacmd list-sinks | grep '*' | tr \* ' ' | awk '/index:/{print $2}')
	else
		# There was a match, so use that
		SINKS=$RUNSINK
	fi
fi

#MSG_ID=$(echo "control_volume" | md5sum | head -c4 | awk '{print "obase=10; ibase=16; " toupper($1)}' | bc)
MSG_ID_FILE="$XDG_RUNTIME_DIR/notifications/volume"

show_help() {
	echo "Usage: control_volume COMMAND <args>"
	echo "Commands:"
	echo "    toggle_mute [DEVICES]"
	echo "    lower [DEVICES]"
	echo "    raise [DEVICES]"
}

do_cmd_many() {
	CMD=$1
	ARGS=$2
	shift
	shift
    SINKS="$@"
	for SINK in $SINKS
	do
		$CMD $SINK $ARGS
	done
}

do_get_volume_many() {
	SINKS=$@
	SINKS_DETAILS=$(pacmd list-sinks | \
				  grep -e 'index' -e 'volume:' -e 'device.description' -e 'muted' | \
				  grep -e 'base volume' -v)

	for SINK in $SINKS
	do
		SINK_DETAILS=$(echo "$SINKS_DETAILS" | grep -e "index: $SINK" -A 3 | grep -e index -v)
		SINK_VOLUME=$(echo "$SINK_DETAILS" | grep "volume" | awk '{print $5}' | sed -e 's/%//')
		SINK_MUTED=$(echo "$SINK_DETAILS" | grep "muted: yes")
		SINK_NAME=$(echo "$SINK_DETAILS" | grep "description" | cut -d '"' -f 2 | cut -d '[' -f 1 | cut -d '(' -f 1 | sed 's/[[:space:]]*$//')

		if [ "$SINK_VOLUME" -eq 0 ] || [ "$SINK_MUTED" ]
		then
			echo "$SINK_NAME: ---"
		else
			echo "$SINK_NAME: ${SINK_VOLUME}%"
		fi
	done
}

send_notify() {
	SINKS=$@
	echo
	if [ $# -gt 1 ]; then
		VOLUMES=$(do_get_volume_many $SINKS)

		notify-send.sh  "$VOLUMES" \
						-t 2000 \
						-a "control_volume" \
						-u low \
						-i audio-volume-high \
						-R "$MSG_ID_FILE"
	else
		# Only expect 1 answer
		VOLUMES=$(do_get_volume_many $SINKS)
		SVOL=$(echo $VOLUMES | cut -d':' -f2 | cut -d'%' -f1)
		case $SVOL in
			*"---"*)
				SSVOL="0"
				;;
		esac

		echo $(printf "%.0f\n" $SVOL)

		notify-send.sh  "$VOLUMES" \
						-t 2000 \
						-a "control_volume" \
						-u low \
						-i audio-volume-high \
						-h int:value:$(printf "%.0f\n" $SVOL) \
						-R "$MSG_ID_FILE"
	fi
}

case $COMMAND in
	"toggle_mute")
		#pactl set-sink-mute $SINKS toggle
		do_cmd_many "pactl set-sink-mute" "toggle" $SINKS
		send_notify $SINKS
		break
		;;
	"lower")
		#pactl set-sink-volume $SINKS -5%
		do_cmd_many "pactl set-sink-volume" "-5%" $SINKS
		send_notify $SINKS
		break
		;;
	"raise")
		#pactl set-sink-volume $SINKS +5%
		do_cmd_many "pactl set-sink-volume" "+5%" $SINKS
		send_notify $SINKS
		break
		;;
	*)
		show_help
		;;
esac
