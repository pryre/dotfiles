#!/bin/sh

DEVICE=$(ifconfig | grep "$1") #Get list of broadcast devices

PROFILE=$2
if [ -z "$PROFILE" ];
then
	#Select the first profile to use
	PROFILE=$(netctl list | grep "$1" | head -n1)
	
	#Strip the star if it exists
	PROFILE_STAR=$(echo "$PROFILE" | cut -d' ' -f2)
	if [ -n "$PROFILE_STAR" ];
	then
		PROFILE=$PROFILE_STAR
	fi
	
fi

case "$DEVICE" in
	#Case: the device is a hardwire device
	"eno"* | "eth"* | "usb"*)
		echo -e "<tool>Wired status for $1\nProfile: $PROFILE</tool>"

		CONN=$(echo "$DEVICE" | grep 'RUNNING')
		echo $CONN
		if [ -z "$CONN" ];
		then
			#Connection is not running
			echo "<img>/home/pryre/.icons/la-capitaine-icon-theme/devices/scalable/network-wired-acquiring.svg</img>"
		else
			#Connection up and running
			echo "<img>/home/pryre/.icons/la-capitaine-icon-theme/devices/scalable/network-wired-symbolic.svg</img>"
		fi
		
		echo "<click>netctl stop $PROFILE</click>"
	;;
	#Case: the device is a wireless device
	"wl"*)
		#ROFILE=$(netctl-auto list | grep "*")
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
	;;
	#Case: the device could not be found
	*)
		echo -e "<tool>Status for $1\nProfile: $PROFILE</tool>"
		echo "<img>/home/pryre/.icons/la-capitaine-icon-theme/devices/scalable/network-wired-disconnected.svg</img>"
		echo "<click>netctl start $PROFILE</click>"
	;;
esac
