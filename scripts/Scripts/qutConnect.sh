#!/bin/bash
read -p "Username: " VPN_USER
read -s -p "Password: " VPN_PASS
echo

echo -n $VPN_PASS | sudo openconnect -u $VPN_USER --passwd-on-stdin sas.qut.edu.au &
#sudo openconnect sas.qut.edu.au

VPN_PID=$!

echo "VPN started on PID $VPN_PID"

echo "Redirecting all traffic over tunnel"
sudo route add -net 0.0.0.0/0 tun0

read -p "Press any key to close..."

echo "Killing VPN"
kill $VPN_PID

