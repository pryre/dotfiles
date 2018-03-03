#!/bin/sh

sudo systemctl start systemd-nspawn@steamcontainer.service
machinectl shell pryre@steamcontainer /usr/bin/steam
sudo systemctl stop systemd-nspawn@steamcontainer.service
