#!/bin/bash
check_git_status() {
	if [ -z "$(git status --porcelain)" ]
	then
		#echo "clean"
		true
	else
		echo "$(tput bold)$(basename $(pwd))$(tput sgr0)"
		git status
		echo "---"
	fi
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
