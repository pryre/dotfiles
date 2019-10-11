#!/bin/sh

if [ "$#" -ne 1 ]
then
    echo "Usage: latex_clean_quicklog file.tex"
    return 1
fi

. $HOME/Scripts/latex_clean_getbuilddir.sh

cat ${BUILD_DIR}/${BNAME}.log | grep "LaTeX Warning\|LaTeX Error"
cat ${BUILD_DIR}/${BNAME}.log | grep -F '!' -A3
