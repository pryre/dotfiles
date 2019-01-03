#!/bin/bash
#echo Shutting down WiFi adapter...
#ip link set wlp2s0 down

echo Changing MAC address...

#Generate random key
hexchars="0123456789ABCDEF"
end=$( for i in {1..6} ; do echo -n ${hexchars:$(( $RANDOM % 16 )):1} ; done | sed -e 's/\(..\)/:\1/g' )

#Attach key to known manufacturer's ID
whole=00:F4:8D$end

echo Stetting MAC to: $whole
ip link set wlan0 down
ip link set wlan0 address $whole

#echo Enabling WiFi adapter...
#ip link set wlp2s0 up

DISPLAY=:0.0 notify-send "Randomized MAC Address"

echo Done!
