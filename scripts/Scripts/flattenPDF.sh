#!/bin/sh

FILENAME="$(basename -s .pdf $1)"

gs -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite \
    -sColorConversionStrategy=/LeaveColorUnchanged  \
    -dAutoFilterColorImages=true \
    -dAutoFilterGrayImages=true \
    -dDownsampleMonoImages=true \
    -dDownsampleGrayImages=true \
    -dDownsampleColorImages=true \
    -sOutputFile="$FILENAME"_flat.pdf "$1"
