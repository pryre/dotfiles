#!/bin/sh

TMPD="${XDG_RUNTIME_DIR}/license-updater"
mkdir -p "$TMPD"

show_help() {
	echo "Usage: license-updater.sh [TYPE [FOLDER ...]]"
	echo "       TYPE: license name (default: MPLv2)"
	echo "       FOLDER: working directory, can specify multiple (default: .)"
	echo "       "
	echo "       Pass the parameter FINDARGS='...' to control search pattern (e.g. -maxdepth 1)"
}

if [ "$1" = "--help" ]
then
	show_help()
	return
fi

# Default to MPLv2
LIC=$1
if [ -z $LIC ]
then
	LIC="MPLv2"
fi

case $1 in
	#Room for other options: eg. gplv3
	MPLv2)
		LIC_C="/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */"

		LIC_S="# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/."

		LIC_M="% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at https://mozilla.org/MPL/2.0/."

		LIC_W='<!-- This Source Code Form is subject to the terms of the Mozilla Public
   - License, v. 2.0. If a copy of the MPL was not distributed with this
   - file, You can obtain one at https://mozilla.org/MPL/2.0/. -->'
		;;
	*)
		echo "Unsupported license: $LIC"
		return
esac

write_license() {
	#Arg1: file to update
	#Arg2: license to use
	TMPF="${TMPD}/$(basename $1).tmp"
	{ echo "$2\n"; cat "$1"; } > "$TMPF"
	mv "$TMPF" "$1"
}

detect_and_write() {
	for f in $(find "$1" $FINDARGS -name '*.c' -o -name '*.cc' -o -name '*.cpp' -o -name "*.h" -o -name "*.hpp")
	do
		echo "\t$f"
		write_license "$f" "$LIC_C"
	done

	for f in $(find "$1" $FINDARGS -name '*.py' -o -name '*.sh' -o -name 'CMakeLists.txt')
	do
		echo "\t$f"
		write_license "$f" "$LIC_S"
	done

	for f in $(find "$1" $FINDARGS -name '*.m')
	do
		echo "\t$f"
		write_license "$f" "$LIC_M"
	done

	for f in $(find "$1" $FINDARGS -name '*.xml' -o -name '*.md')
	do
		echo "\t$f"
		write_license "$f" "$LIC_W"
	done
}

if [ $# -ge 2 ]
then
	# Shift out lisence arg and
	shift
	for folder in "$@"
	do
		echo "Appling to: $folder"
		detect_and_write "$folder"
	done
else
	echo "Appyling to current directory"
	detect_and_write '.'
fi

