#!/bin/sh

if [ "$#" -ne 1 ]
then
    echo "Usage: latex_clean_build file.tex"
    return 1
fi

RPATH=$(realpath $1)
BNAME=$(basename -s .tex $RPATH)
BASE_FILE="$(dirname $RPATH)/$BNAME"
BUILD_DIR="$XDG_RUNTIME_DIR/latex/$(echo $BASE_FILE | tr '/' '_' | tail -c 250)"

mkdir -p $BUILD_DIR
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
	cp $BUILD_DIR/$BNAME.pdf .
fi
