#!/bin/sh

OUTDIR="./[MP3] ${PWD##*/}"
mkdir -p "$OUTDIR"

for f in ./*.flac; do
	echo "Processing: $f"
	ffmpeg -i "$f" -qscale:a 0 -loglevel quiet "$OUTDIR/${f%.*}.mp3"
done

