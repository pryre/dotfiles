#!/bin/sh

if [ "$#" -ne 1 ]
then
    echo "Usage: latex_gui file.tex"
    return 1
fi

FNAME=$1
PNAME="$(basename -s .tex $FNAME).pdf"

#Perform a clean build first to create the environment
~/Scripts/latex_clean_build.sh $FNAME

HOMERC=". $HOME/.bashrc"
#LOGCMD="~/Scripts/latex_clean_quicklog.sh $FNAME"
BIBCMD="~/Scripts/latex_clean_bibtex.sh $FNAME"
AUTCMD="~/Scripts/latex_autobuild.sh $FNAME"
PDFCMD="~/Scripts/pdf_open_refresh.sh $PNAME"

BASH_PRE="/bin/bash --init-file <(echo run\(\){ "
BASH_LAT=" \; }\;run)"

#alacritty --title 'Latex GUI [quicklog]' -e bash -c "${BASH_PRE}${HOMERC} \; ${LOGCMD}${BASH_LAT}" &
#PID_LOG=$!
alacritty --title 'Latex GUI [bibtex]' -e bash -c "${BASH_PRE}${HOMERC} \; ${BIBCMD}${BASH_LAT}" &
PID_BIB=$!
alacritty --title 'Latex GUI [autobuild]' -e bash -c "${BASH_PRE}${HOMERC} \; ${AUTCMD}${BASH_LAT}" &
PID_AUT=$!
alacritty --title 'Latex GUI [pdf]' -e bash -c "${BASH_PRE}${HOMERC} \; ${PDFCMD}${BASH_LAT}" &
PID_PDF=$!

nano $FNAME

kill $PID_LOG $PID_BIB $PID_AUT $PID_PDF 2> /dev/null
