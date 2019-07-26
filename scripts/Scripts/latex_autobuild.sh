#!/bin/sh

if [ "$#" -ne 1 ]
then
	echo "Usage: latex_autobuild file.tex"
	return 1
fi

PDF_F=$1
while inotifywait -e modify -e access -e attrib "$PDF_F"
do
	echo "$PDF_F modified"
	$HOME/Scripts/latex_clean_build.sh "$PDF_F"

	echo "--- Quicklog ---"
	$HOME/Scripts/latex_clean_quicklog.sh "$PDF_F"
	echo "----------------"
done
