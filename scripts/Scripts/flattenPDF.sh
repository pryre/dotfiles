#!/bin/bash

filename="${$1%.*}"

gs -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite \
    -sColorConversionStrategy=/LeaveColorUnchanged  \
    -dAutoFilterColorImages=true \
    -dAutoFilterGrayImages=true \
    -dDownsampleMonoImages=true \
    -dDownsampleGrayImages=true \
    -dDownsampleColorImages=true \
    -sOutputFile=filename_flat.pdf $1
