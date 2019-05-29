#!/bin/sh
COMMAND=$1
shift
SINKS="$@"

#MSG_ID=$(echo "control_volume" | md5sum | head -c4 | awk '{print "obase=10; ibase=16; " toupper($1)}' | bc)

if [ -z $SINKS ]
then
	SINKS=$(pacmd list-sinks |awk '/* index:/{print $3}')
fi

show_help() {
	echo "Usage: control_volume COMMAND <args>"
	echo "Commands:"
	echo "    toggle_mute [DEVICES]"
	echo "    lower [DEVICES]"
	echo "    raise [DEVICES]"
}

send_notify() {
	VOLUME=$(pactl list sinks | grep "Volume:" | grep -v "Base" | awk '{print $5}' | sed -e 's/%//')
	MUTE=$(pactl list sinks | grep "Mute: yes")

	if [ "$VOLUME" -eq 0 ] || [ "$MUTE" ]
	then
		# Show the sound muted notification
		#dusntify -t 2000 -a "changeVolume" -u low -i audio-volume-low -r "$MSG_ID" "Volume: ---"
		notify-send -t 2000 -a "control_volume" -u low -i audio-volume-low "Volume: ---"
	else
		# Show the volume notification
		#dunstify -t 2000 -a "changeVolume" -u low -i audio-volume-high -r "$MSG_ID" "Volume: ${VOLUME}%"
		notify-send -t 2000 -a "control_volume" -u low -i audio-volume-high "Volume: ${VOLUME}%"
	fi
}

case $COMMAND in
	"toggle_mute")
		pactl set-sink-mute $SINKS toggle
		send_notify
		break
		;;
	"lower")
		pactl set-sink-volume $SINKS -5%
		send_notify
		break
		;;
	"raise")
		pactl set-sink-volume $SINKS +5%
		send_notify
		break
		;;
	*)
		show_help
		;;
esac
