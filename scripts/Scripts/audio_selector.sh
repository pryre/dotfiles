#!/bin/sh

AUDIO_OUT_STATUS=$(pactl list modules | grep rtp)

if [ -z "$AUDIO_OUT_STATUS" ];
then #Connection is not using rtp
	AUDIO_OUT_STATUS="headphones"
	IMG_PATH="<img>/home/pryre/.icons/la-capitaine-icon-theme/devices/symbolic/audio-headphones-symbolic.svg</img>"
	ON_CLICK="<click>/home/pryre/Scripts/audio_selector_rtp.sh</click>"
else #Connection is using rtp
	AUDIO_OUT_STATUS="rtp"
	IMG_PATH="<img>/home/pryre/.icons/la-capitaine-icon-theme/devices/symbolic/audio-speakers-symbolic.svg</img>"
	ON_CLICK="<click>/home/pryre/Scripts/audio_selector_headphones.sh</click>"
fi

TOOLTIP="<tool>Default output set to: $AUDIO_OUT_STATUS</tool>"

echo "$TOOLTIP"
echo "$IMG_PATH"
echo "$ON_CLICK"
