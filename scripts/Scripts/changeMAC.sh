#!/bin/sh

DEV=$1

if [ -z $DEV ]
then
	echo "No device ID specified"
	exit 1
fi

echo Changing MAC address...

ADDR=$(ip link show $DEV | grep 'link/ether' | cut -d ' ' -f 6)

#Generate random key
#END=$( for i in {1..6} ; do echo -n ${HEXCHARS:$(( $RANDOM % 16 )):1} ; done | sed -e 's/\(..\)/:\1/g' )

#Leave the manufacturer's ID in tact
ADDR1=$(echo $ADDR | cut -d':' -f1)
ADDR2=$(echo $ADDR | cut -d':' -f2)
ADDR3=$(echo $ADDR | cut -d':' -f3)
#Generate random ID
HEXCHARS="0123456789abcdef"
ADDR4=${HEXCHARS:$(( $RANDOM % 16 )):2}
ADDR5=${HEXCHARS:$(( $RANDOM % 16 )):2}
ADDR6=${HEXCHARS:$(( $RANDOM % 16 )):2}
NEWADDR=$ADDR1:$ADDR2:$ADDR3:$ADDR4:$ADDR5:$ADDR6

echo "Changing $DEV MAC from $ADDR to $NEWADDR"
ip link set wlan0 down
ip link set wlan0 address $NEWADDR

DISPLAY=:0.0 notify-send "Randomized MAC Address"

echo Done!
