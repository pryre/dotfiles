#!/bin/sh

if [[ -z $XDG_DATA_HOME ]]
then
	XDG_DATA_HOME="$HOME/.local/share"
fi

if [[ -z $XDG_DATA_DIRS ]]
then
	XDG_DATA_DIRS="/usr/local/share:/usr/share"
fi

APP_DIRS=$(echo "$XDG_DATA_HOME:$XDG_DATA_DIRS" | tr ':' '\n' | sed -e 's|$|/applications|')

find -L $APP_DIRS -maxdepth 1 -type f -name '*.desktop' 2> /dev/null
