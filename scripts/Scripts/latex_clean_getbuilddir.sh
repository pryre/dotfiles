#!/bin/sh

if [ "$#" -ne 1 ]
then
    echo "Usage: latex_clean_getbuilddir file.tex"
    return 1
fi

RNAME=$(realpath "$1")
export RPATH="$RNAME"
export BNAME=$(basename -s .tex "$RPATH")
BASE_FILE=$(dirname "$RPATH")/$BNAME
export BUILD_DIR="$XDG_RUNTIME_DIR/latex/$(echo $BASE_FILE | tr '/' '_' | tr ' ' '_' | tail -c 250)"

mkdir -p "$BUILD_DIR"

#echo "$BUILD_DIR"
