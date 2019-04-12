#!/bin/sh

APP_DIR_SYSTEM=~/.local/share/applications/
APP_DIR_LOCAL=/usr/share/applications/

find -L $APP_DIR_SYSTEM $APP_DIR_LOCAL -maxdepth 1 -type f -name '*.desktop' #-execdir basename '{}' ';' | awk -F '.desktop' ' { print $1}'