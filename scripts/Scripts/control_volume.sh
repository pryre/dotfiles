#!/bin/sh

COMMAND=$1
SINK_LIST=$(pactl list sinks)
SINKS=""
if [ $# -ge 2 ]
then
	if [ $2 = '-a' ]
	then
		# Use all sinks if flagged
		SINKS=$(echo "$SINK_LIST" | grep -e 'Sink #' | cut -d '#' -f 2) # tr \* ' ' | awk '/Sink #/{print $2}')
	else
		# Use list of sinks if provided
		shift
		SINKS="$@"
	fi
else
	# Grab first running sink if we have one
	RUNSINK=$(echo "$SINK_LIST" | grep -e 'Sink #' -e 'State' | sed -n '/RUNNING/{x;p;d;}; x' | head -n 1 | cut -d'#' -f2)
	if [ -z "$RUNSINK" ]
	then
		# No match, use default sink if none provided
		# XXX: This probably doesn't work
		# SINKS=$(echo "$SINK_LIST" | grep '*' | grep -e 'Sink #' | cut -d '#' -f 2)

		# Try get an idle or suspended sink instead
		SINKS=$(echo "$SINK_LIST" | grep -e 'Sink #' -e 'State' | sed -n -E '/SUSPENDED|IDLE/{x;p;d;}; x' | head -n 1 | cut -d'#' -f2)
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
	SINKS_DETAILS=$(pactl list sinks | \
					grep -e 'Sink #' -e 'Volume' -e 'node.nick' -e 'Mute' | \
					grep -e 'Base Volume' -v)
				  # grep -e 'index' -e 'volume:' -e 'node.nick' -e 'muted' | \
				  # grep -e 'base volume' -v)

	for SINK in $SINKS
	do
		SINK_DETAILS=$(echo "$SINKS_DETAILS" | grep -e "Sink #$SINK" -A 3 | grep -e "Sink #" -v)
		SINK_VOLUME=$(echo "$SINK_DETAILS" | grep -e "Volume" | cut -d '/' -f 2 | sed -e 's/^[[:space:]]*//' -e 's/[[:blank:]]*$//' -e 's/%//')
		SINK_MUTED=$(echo "$SINK_DETAILS" | grep "Mute: yes")
		SINK_NAME=$(echo "$SINK_DETAILS" | grep "node.nick" | cut -d '=' -f 2 | sed -e 's/^[[:space:]]*//' -e 's/[[:blank:]]*$//' -e 's/"//g') #  cut -d '[' -f 1 | cut -d '(' -f 1 | sed 's/[[:space:]]*$//')

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

		# echo $(printf "%.0f\n" $SVOL)

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
		#pactl set-sink-mute $SINK toggle
		do_cmd_many "pactl set-sink-mute" "toggle" $SINKS
		send_notify $SINKS
		break
		;;
	"lower")
		#pactl set-sink-volume $SINK -5%
		do_cmd_many "pactl set-sink-volume" "-5%" $SINKS
		send_notify $SINKS
		break
		;;
	"raise")
		#pactl set-sink-volume $SINK +5%
		do_cmd_many "pactl set-sink-volume" "+5%" $SINKS
		send_notify $SINKS
		break
		;;
	*)
		show_help
		;;
esac
