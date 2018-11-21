#!/bin/sh

while read bib; do
	BIB_NAME=$(echo $bib | cut -d' ' -f1)
	BIB_LINK=$(echo $bib | cut -d' ' -f2)
	ln -s $BIB_LINK $BIB_NAME
done < "$1"
