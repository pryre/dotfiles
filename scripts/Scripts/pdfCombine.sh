#!/bin/sh

if [ "$#" -gt 1 ]
then
	F_OUT=$1
	F_IN=""

	for VAR in "$@"
	do
		if [ ${VAR} != ${F_OUT} ]
		then
			F_IN="${F_IN} ${VAR}"
		fi
	done

	F_IN_SORT=$(echo "${F_IN}" | tr ' ' '\n' | sort -b | tr '\n' ' ')

	#echo "${F_IN_SORT}"
	gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=${F_OUT} ${F_IN}
else
	echo "Usage: combinePDF.sh /output/File.pdf [ /input/file.pdf ... ]"
fi

