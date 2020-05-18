#!/bin/sh

if [ "$#" -ne 1 ]
then
	echo "Usage: pdf_open_refresh FILE"
	return 1
fi

PDF_F=$1
qpdfview "$PDF_F" &
PID=$!
while inotifywait -e close "$PDF_F"
do
	if [ -z "$(ps --no-headers $PID)" ]
	then
		# mupdf has been closed
		break
	else
		kill -HUP "$PID"
		sleep 1
	fi
done
