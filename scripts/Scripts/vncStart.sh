#!/bin/sh

echo Openning x0vncserver on IPs:
ip -4 addr | grep -oP '(?<=inet\s)\d+(\.\d+){3}'

x0vncserver \
	-display :0 \
	-rfbauth ~/.vnc/passwd
