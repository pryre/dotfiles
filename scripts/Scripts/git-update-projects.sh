#!/bin/bash

check_git_update() {
	echo "$(tput bold)$(basename $(pwd))$(tput sgr0)"

	git pull

	echo "---"
}

export -f check_git_update

PARENT_DIR="."

if [ ! -z $1 ]
then
	PARENT_DIR=$1
fi

CURRENT_DIR=$PWD
cd $PARENT_DIR

find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "cd '{}' && check_git_update" \;

cd $CURRENT_DIR
