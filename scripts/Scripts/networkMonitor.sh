#!/bin/sh

DEVICE=$(ifconfig | grep "$1") #Get list of broadcast devices

case "$DEVICE" in
	#Case: the device is a hardwire device
	"eno"* | "eth"* | "usb"*)
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
	;;
	#Case: the device is a wireless device
	"wl"*)
		ROFILE=$(netctl-auto list | grep "*")
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
		echo "<img>/home/pryre/.icons/la-capitaine-icon-theme/devices/scalable/network-wired-disconnected.svg</img>"
	;;
esac
