#!/bin/sh

extract_pages() {
		SHORT_FILE=$(echo $1 | cut -d. -f1)

		gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER \
			-dFirstPage=$2 -dLastPage=$3 \
			-sOutputFile="split-$2-$3.pdf" "$1"
}

case "$#" in
	1)
		#Extract all pages
		PG_NUM=$(gs -q -dNODISPLAY -dNOSAFER -c \
				 "($1) (r) file runpdfbegin pdfpagecount = quit")

		for i in $(seq -w $PG_NUM); do
			extract_pages "$1" "$i" "$i"
		done
	;;
	3)
		extract_pages "$1" "$2" "$3"
	;;
	*)
		echo "Usage: pdfExtract.sh FILE [start end]"
		echo "If 'start' and 'end' are ommitted, all pages are extracted separately"
	;;
esac


