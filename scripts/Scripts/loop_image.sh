#!/bin/sh

if [ $# -eq 1 ]
then
	IMAGE=$1

	sudo -v
	sudo modprobe loop
	LOOP=$(losetup -f)
	sudo losetup $LOOP $IMAGE
	sudo partprobe $LOOP

	echo "Loopback deice loaded at: $LOOP"
	echo "To unload device: losetup -d $LOOP"
else
	echo 'Usage: loop_image.sh FILE'
fi