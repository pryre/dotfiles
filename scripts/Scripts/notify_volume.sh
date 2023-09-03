#!/bin/sh

STATUS=$(wpctl get-volume @DEFAULT_SINK@)
VOLUME=$(echo $STATUS | cut -d" " -f 2)
MUTE=$(echo $STATUS | cut -d" " -f 3)
VOLUME_NUM=$(echo "$VOLUME * 100" | bc)
VOLUME_NUM_TEXT="$VOLUME_NUM%"
ICON="audio-volume-high"

if [ -z "$MUTE" ]
then
	false
else
	ICON="audio-volume-mute"
	VOLUME_NUM="0"
	VOLUME_NUM_TEXT="---"
fi


MSG_ID_FILE="$XDG_RUNTIME_DIR/notifications/volume"
notify-send.sh  "Volume: $VOLUME_NUM_TEXT" \
				-t 2000 \
				-a "control_volume" \
				-u low \
				-i $ICON \
				-h int:value:$(printf "%0.0f" $VOLUME_NUM) \
				-R "$MSG_ID_FILE"

