#!/bin/sh

tdir=$(mktemp -d /tmp/latex_svg.XXXXXXXXX)
cd "$tdir"
filename="latex$$"

tex_input='\documentclass[12pt,border={1pt 1pt 1pt 1pt}]{standalone} \usepackage{times} \usepackage{mathtools} \usepackage{amssymb} \begin{document}'

pdflatex -jobname="$filename" "$tex_input" "$1" '\end{document}'

cd - > /dev/null

#cp "$tdir/$filename.pdf" ./

pdf2svg "$tdir/$filename.pdf" "$filename.svg"
