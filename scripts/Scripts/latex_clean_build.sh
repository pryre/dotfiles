#!/bin/sh

if [ "$#" -ne 1 ]
then
    echo "Usage: latex_clean_build file.tex"
    return 1
fi

INPUT_TEX=$1

#RPATH=$(realpath $1)
#BNAME=$(basename -s .tex $RPATH)
#BASE_FILE="$(dirname $RPATH)/$BNAME"
#BUILD_DIR="$XDG_RUNTIME_DIR/latex/$(echo $BASE_FILE | tr '/' '_' | tail -c 250)"

#mkdir -p $BUILD_DIR

. $HOME/Scripts/latex_clean_getbuilddir.sh $INPUT_TEX
echo "Building in $BUILD_DIR"

export max_print_line=10000

LFLAGS="-interaction=nonstopmode --output-directory $BUILD_DIR"
#pdflatex -output-directory "$BUILD_DIR" "$RPATH"
OUTNAME=$(pdflatex $LFLAGS "$RPATH" | grep -F "Output written on")
if [ -z "$OUTNAME" ]
then
	# The build failed
	echo "Error: Output file not produced!"
	return 1
else
	echo "Output produced"
	cp "$BUILD_DIR/$BNAME.pdf" .

	if [ -f "$BUILD_DIR/$BNAME.pdfpc" ]
	then
		cp "$BUILD_DIR/$BNAME.pdfpc" .
		# Hack to clean-up poor handling of exported notes
		sed -i 's/\\\\/\n/g' "$BNAME.pdfpc"
		sed -i 's/\\par/\n\n/g' "$BNAME.pdfpc"
	fi

	# Hack to deal with .cpc not looking in correct directory
	if [ -f "$BUILD_DIR/$BNAME.cpc" ]
	then
		cp "$BUILD_DIR/$BNAME.cpc" .
	fi
fi
