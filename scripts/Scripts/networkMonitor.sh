#!/bin/bash

DEVICE=$(ifconfig | grep "$1") #Get list of broadcast devices

E_DEV="eno"
W_DEV="wlp"

if [ -z "$DEVICE" ];
then
	#Device not available
	echo "<img>/home/pryre/.icons/la-capitaine-icon-theme/devices/scalable/network-wired-disconnected.svg</img>"
else
	if [[ "$DEVICE" == *"$E_DEV"* ]]; then
		PROFILE=$(netctl list | grep "*")
		echo -e "<tool>Wired status for $1</tool>"

		CONN=$(echo "$DEVICE" | grep 'RUNNING')
		if [ -z "$CONN" ];
		then
			#Connection is not running
			echo "<img>/home/pryre/.icons/la-capitaine-icon-theme/devices/scalable/network-wired-acquiring.svg</img>"
		else
			#Connection up and running
			echo "<img>/home/pryre/.icons/la-capitaine-icon-theme/devices/scalable/network-wired-symbolic.svg</img>"
		fi
	fi

	if [[ "$DEVICE" == *"$W_DEV"* ]]; then
		PROFILE=$(netctl-auto list | grep "*")
		echo -e "<tool>Wireless status for $1\nProfile: $PROFILE</tool>"

		CONN=$(echo "$DEVICE" | grep 'RUNNING')
		if [ -z "$CONN" ];
		then
			#Connection is not running
			echo "<img>/home/pryre/.icons/la-capitaine-icon-theme/devices/scalable/network-wireless-connected-25.svg</img>"
	        echo "<click>netctl-auto enable-all</click>"
		else
			#Connection up and running
			echo "<img>/home/pryre/.icons/la-capitaine-icon-theme/devices/scalable/network-wireless-connected-100.svg</img>"
	        echo "<click>netctl-auto disable-all</click>"
		fi
	fi
fi
