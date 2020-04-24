#!/bin/bash

#ROOT_UID=0     		#$UID for root privileges.
#EXIT_NOTROOT=87   	#Non-root exit error.
#EXIT_USER=10		#User ended exit.
#EXIT_PING=88		#Ping test faied exit error.

#if [ "$UID" -ne "$ROOT_UID" ]
#then
#  echo "Must be ran as root!"
#  exit $EXIT_NOTROOT
#fi

#Wicd Script=======================
sudo systemctl stop netctl-auto@wlan0.service

echo "Randomizing MAC..."
sudo ~/Scripts/changeMAC.sh wlan0

echo "Enabling network..."
sudo systemctl start netctl-auto@wlan0.service

while [ -z "$(netctl-auto list | grep '*')" ]
do
	sleep 0.5
done

xdg-open "https://www.queenslandrail.com.au/wi-fi/"

#echo "Network connected!"
#echo "Waiting for internet access..."
#sleep 6

#Access Portal=====================

#DISPLAY=:0.0 /bin/notify-send "Openning access portal"

#python2 ~/Scripts/auto_train_login.py

#case $? in
#	0)
#		DISPLAY=:0.0 /bin/notify-send "Internet access achieved"
#		;;
#	1)
#		DISPLAY=:0.0 /bin/notify-send "Error connecting to Internet"
#		;;
#	2)
#		DISPLAY=:0.0 /bin/notify-send "Internet access was already granted..."
#		;;
#	*)
#		DISPLAY=:0.0 /bin/notify-send "Openning access portal"
#		;;
#esac


#DISPLAY=:0.0 firefox http://www.queenslandrail.com.au/wi-fi/
#DISPLAY=:0.0 firefox http://10.1.83.1:4990/www/login.chi

exit 0										#End script.
