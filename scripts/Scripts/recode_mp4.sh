#!/bin/sh

# This script will open all video files passed to it, and recode them as .mp4 with "good" settings

CMD='ffmpeg -i $var -crf 18 -c:a copy -pix_fmt yuv420p recode_$(basename "$var" | cut -f1 -d'.').mp4'

for var in "$@"
do
	echo "Proccessing: $var"
	echo
	eval $CMD
done
