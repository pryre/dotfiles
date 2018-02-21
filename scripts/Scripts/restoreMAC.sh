#!/bin/bash

#if [ "$UID" -ne "$ROOT_UID" ]
#then
#  echo "Must be ran as root!"
#  exit $EXIT_NOTROOT
#fi

echo Shutting down WiFi adapter...
sudo ip link set wlp2s0 down

echo Restoring MAC address...
whole=$(ethtool -P wlp2s0 | awk '{print $3}')
echo Stetting MAC to: $whole
sudo ip link set wlp2s0 address $whole

echo Enabling WiFi adapter...
sudo ip link set wlp2s0 up

DISPLAY=:0.0 notify-send "Restored MAC Address"

echo Done!
