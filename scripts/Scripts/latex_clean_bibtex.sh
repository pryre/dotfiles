#!/bin/sh

if [ "$#" -ne 1 ]
then
    echo "Usage: latex_clean_build file.tex"
    return 1
fi

. $HOME/Scripts/latex_clean_getbuilddir.sh

#RPATH=$(realpath $1)
#BNAME=$(basename -s .tex $RPATH)
#BASE_FILE="$(dirname $RPATH)/$BNAME"
#BUILD_DIR="$XDG_RUNTIME_DIR/latex/$(echo $BASE_FILE | tr '/' '_' | tail -c 250)"

#mkdir -p $BUILD_DIR
rm $BUILD_DIR/references 2> /dev/null
ln -s $(realpath references) $BUILD_DIR/references

cp ./*.bst "$BUILD_DIR" 2> /dev/null

cd $BUILD_DIR
bibtex $BNAME.aux
