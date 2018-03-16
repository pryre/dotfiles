#!/bin/bash
read -p "Username: " VPN_USER
read -s -p "Password: " VPN_PASS
#PIDFILE=/run/openconnect_${Interface}.pid
echo

echo -n $VPN_PASS | sudo openconnect -u $VPN_USER --passwd-on-stdin sas.qut.edu.au
#sudo openconnect sas.qut.edu.au

#echo "Redirecting all traffic over tunnel"
#sudo route add -net 0.0.0.0/0 tun0

#read -p "Press any key to close..."

#echo "Killing VPN"
#kill -INT $(cat ${PIDFILE})
