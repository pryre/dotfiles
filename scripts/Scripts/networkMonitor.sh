#!/bin/sh

NIPATH="$HOME/.local/share/icons/la-capitaine-icon-theme/devices/scalable/"
NINAME_DISCONNECTED="network-wired-disconnected.svg"
NINAME_ETH_WAITING="network-wired-acquiring.svg"
NINAME_ETH_CONNECTED="network-wired-symbolic.svg"
NINAME_WL_BLOCKED="network-wireless-disconnected.svg"
NINAME_WL_UNBLOCKED="network-wireless-connected-25.svg"
NINAME_WL_CONNECTED="network-wireless-connected-100.svg"

DEVICE=$1
CONN_STATUS=$(ip addr | grep "$DEVICE" | grep 'state UP')

PROFILE=$2
if [ -z "$PROFILE" ];
then
	PROFILE_ACT=""

	case "$DEVICE" in
		"eno"* | "eth"* | "usb"*) #Case: the device is a hardwire device
			PROFILE_ACT=$(ifplugstatus | grep $DEVICE | cut -d ' ' -f2)

			if [ -z "$CONN_STATUS" ];
			then #Connection is not running
				ON_CLICK="<click>systemctl restart netctl-ifplugd@$1</click>"
			else #Connection up and running
				ON_CLICK="<click>systemctl stop netctl-ifplugd@$1</click>"
			fi
		;;
		"wl"*) #Case: the device is a wireless device
			PROFILE_ACT=$(netctl-auto list | grep "*" | tr -d '* ')
			if [ -z "$PROFILE_ACT" ];
			then
				PROFILE_ACT="[disconnected]"
			fi

			if [ -z "$CONN_STATUS" ];
			then #Connection is not running
				ON_CLICK="<click>systemctl restart netctl-auto@$1</click>"
			else #Connection up and running
				ON_CLICK="<click>systemctl stop netctl-auto@$1</click>"
			fi
		;;
		*) #Case: the device type could not be found
		;;
	esac

	if [ -z "$PROFILE_ACT" ];
	then #Profile status could not be determined
		PROFILE="[unknown]"
	else #Profile is automiatically managed, insert text
		PROFILE="[auto] $PROFILE_ACT"
	fi
else
	if [ -z "$CONN_STATUS" ];
	then #Connection is not running
		ON_CLICK="<click>netctl restart $PROFILE</click>"
	else #Connection up and running
		ON_CLICK="<click>netctl stop $PROFILE</click>"
	fi
fi

# Set the default icon (disconnected/doesn't exist)
IMG_PATH="<img>${NIPATH}${NINAME_DISCONNECTED}</img>"
TOOLTIP_PRE="Status"

case "$DEVICE" in
	"eno"* | "eth"* | "usb"*) #Case: the device is a hardwire device
		TOOLTIP_PRE="Wired status"

		if [ -z "$CONN_STATUS" ];
		then #Connection is not running
			IMG_PATH="<img>${NIPATH}${NINAME_ETH_WAITING}</img>"
		else #Connection up and running
			IMG_PATH="<img>${NIPATH}${NINAME_ETH_CONNECTED}</img>"
		fi

	;;
	"wl"*) #Case: the device is a wireless device
		TOOLTIP_PRE="Wireless status"

		if [ -z "$CONN_STATUS" ];
		then #Connection is not running
			RF_STATUS=$(rfkill --noheadings | grep wlan | grep " blocked")

			if [ -z "$RF_STATUS" ];
			then #Connection is unblocked
				IMG_PATH="<img>${NIPATH}${NINAME_WL_UNBLOCKED}</img>"
			else
				#Connection is blocked
				IMG_PATH="<img>${NIPATH}${NINAME_WL_BLOCKED}</img>"
			fi
		else #Connection up and running
			IMG_PATH="<img>${NIPATH}${NINAME_WL_CONNECTED}</img>"
		fi
	;;
	*) #Case: the device type could not be found
	;;
esac

#TOOLTIP="<tool>$TOOLTIP_PRE for $1\nProfile: $PROFILE</tool>"
#echo -e "$TOOLTIP"
echo "<tool>$TOOLTIP_PRE for $1"
echo "Profile: $PROFILE</tool>"
echo "$IMG_PATH"
echo "$ON_CLICK"
