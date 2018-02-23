#!/bin/sh

if [ "$#" -eq 2 ]
then
	gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=$1 $2*
else
	echo "Usage: combinePDF.sh /output/File.pdf /input/directory/"
	echo "Or: combinePDF.sh /output/File.pdf /input/files"
	echo "Second option will match all files with the * wildcard"
fi

