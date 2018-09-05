#!/bin/sh

DEVICE=$1
CONN_STATUS=$(ip addr | grep "$DEVICE" | grep 'UP')

PROFILE=$2
if [ -z "$PROFILE" ];
then
	PROFILE_ACT=$(netctl-auto list | grep "*" | tr -d '*')
	if [ -z "$PROFILE_ACT" ];
	then
		PROFILE_ACT="[disconnected]"
	fi

	PROFILE="[auto] $PROFILE_ACT"

	if [ -z "$CONN_STATUS" ];
	then #Connection is not running
		ON_CLICK="<click>systemctl start netctl-auto@$1</click>"
	else #Connection up and running
		ON_CLICK="<click>systemctl stop netctl-auto@$1</click>"
	fi
else
	if [ -z "$CONN_STATUS" ];
	then #Connection is not running
		ON_CLICK="<click>netctl start $PROFILE</click>"
	else #Connection up and running
		ON_CLICK="<click>netctl stop $PROFILE</click>"
	fi
fi

# Set the default icon (disconnected/doesn't exist)
IMG_PATH="<img>/home/pryre/.icons/la-capitaine-icon-theme/devices/scalable/network-wired-disconnected.svg</img>"
TOOLTIP_PRE="Status"

case "$DEVICE" in
	"eno"* | "eth"* | "usb"*) #Case: the device is a hardwire device
		TOOLTIP_PRE="Wired status"

		if [ -z "$CONN_STATUS" ];
		then #Connection is not running
			IMG_PATH="<img>/home/pryre/.icons/la-capitaine-icon-theme/devices/scalable/network-wired-acquiring.svg</img>"
		else #Connection up and running
			IMG_PATH="<img>/home/pryre/.icons/la-capitaine-icon-theme/devices/scalable/network-wired-symbolic.svg</img>"
		fi

	;;
	"wl"*) #Case: the device is a wireless device
		TOOLTIP_PRE="Wireless status"

		if [ -z "$CONN_STATUS" ];
		then #Connection is not running
			IMG_PATH="<img>/home/pryre/.icons/la-capitaine-icon-theme/devices/scalable/network-wireless-connected-25.svg</img>"
		else #Connection up and running
			IMG_PATH="<img>/home/pryre/.icons/la-capitaine-icon-theme/devices/scalable/network-wireless-connected-100.svg</img>"
		fi
	;;
	*) #Case: the device type could not be found
	;;
esac

TOOLTIP="<tool>$TOOLTIP_PRE for $1\nProfile: $PROFILE</tool>"

echo -e "$TOOLTIP"
echo "$IMG_PATH"
echo "$ON_CLICK"
