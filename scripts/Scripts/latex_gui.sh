#!/bin/sh

if [ "$(basename -s .tex $1 | grep -F '.tex')" ]; then
	echo "Usage: latex_gui file.tex"
	return 1
fi

cd "$(dirname $1)"

FNAME="$(basename $1)"
PNAME="$(basename -s .tex $FNAME).pdf"

#Perform a clean build first to create the environment
~/Scripts/latex_clean_build.sh $FNAME

HOMERC=". $HOME/.bashrc"
BIBCMD="~/Scripts/latex_clean_bibtex.sh $FNAME"
AUTCMD="~/Scripts/latex_autobuild.sh $FNAME"
PDFCMD="~/Scripts/pdf_open_refresh.sh $PNAME"

BASH_PRE="/bin/bash --init-file <(echo run\(\){ "
BASH_LAT=" \; }\;run)"

alacritty --title "Latex GUI - $FNAME [bibtex]" -e bash -c "${BASH_PRE}${HOMERC} \; ${BIBCMD}${BASH_LAT}" &
PID_BIB=$!
alacritty --title "Latex GUI - $FNAME [autobuild]" -e bash -c "${BASH_PRE}${HOMERC} \; ${AUTCMD}${BASH_LAT}" &
PID_AUT=$!
alacritty --title "Latex GUI - $FNAME [pdf]" -e bash -c "${BASH_PRE}${HOMERC} \; ${PDFCMD}${BASH_LAT}" &
PID_PDF=$!

nano $FNAME

kill $PID_LOG $PID_BIB $PID_AUT $PID_PDF 2> /dev/null

cd - > /dev/null
