#!/bin/sh

# Skim for last option (file name) and check for create flag
#for IFNAME in $@; do :; done
#CREATE_NEW_FILE=false
#if [ $# -ge 2 ] && [ "$1" = '-c' ]; then CREATE_NEW_FILE=true; fi
IFNAME=$(realpath $1)

# Make sure arguments are valid
if [ "$(basename -s .tex $IFNAME | grep -F '.tex')" ]; then
	#echo "Usage: latex_gui [-c] file.tex"
	echo "Usage: latex_gui file.tex"
	return 1
fi

# Helper functions
minimal_template() {
	echo '\\documentclass{article}\n
\\begin{document}\n
\\section{Template}
\\today\n
\\end{document}
'
}

open_gui() {
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
}

# Do rest of code
cd "$(dirname $IFNAME)"

FNAME="$(basename $IFNAME)"
PNAME="$(basename -s .tex $FNAME).pdf"

# Create the file if it does not exist
if [ ! -f "$IFNAME" ]
then
	echo "Creating file: $IFNAME"
	minimal_template > $IFNAME
fi

#Perform a clean build first to create the environment
if ~/Scripts/latex_clean_build.sh $FNAME
then
	open_gui $FNAME $PNAME
else
	echo "Unable to build .tex file, are you sure this is a valid text file?"
fi
