#!/bin/sh

DNAME=$(date +'%Y-%m-%d-%H-%M-%S')
grim "${HOME}/Pictures/${DNAME}_capture.png"
notify-send.sh -i camera "Screenshot Captured" '~/Pictures/'$DNAME
