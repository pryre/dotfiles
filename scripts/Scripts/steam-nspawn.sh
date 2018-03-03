#!/bin/sh

xhost +local:
systemctl start systemd-nspawn@steamcontainer.service
machinectl shell pryre@steamcontainer /usr/bin/steam
systemctl stop systemd-nspawn@steamcontainer.service
