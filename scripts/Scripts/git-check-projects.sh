#!/bin/bash
check_git_status() {
	echo "$(tput bold)$(basename $(pwd))$(tput sgr0)"
	if [ -z "$(git status --porcelain)" ]
	then
		echo "clean"
	else
		git status
	fi

	echo "---"
}

export -f check_git_status

PARENT_DIR="."

if [ ! -z $1 ]
then
	PARENT_DIR=$1
fi

CURRENT_DIR=$PWD
cd $PARENT_DIR

find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "cd '{}' && check_git_status" \; #cd '{}' && pwd && git status && echo ''" \;


cd $CURRENT_DIR
