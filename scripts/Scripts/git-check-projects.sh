#!/bin/sh

check_git_status() {
	START_DIR="$(pwd)"
	cd $1

	if [ -z $(git log origin/master..master) ] && [ -z "$(git status --porcelain)" ]
	then
		#echo "clean"
		true
	else
		echo "$(tput bold)$(basename $(pwd))$(tput sgr0)"
		git status
		echo "---"
	fi

	cd $START_DIR
}

PARENT_DIR="."

if [ $1 ]
then
	PARENT_DIR=$1
fi

CURRENT_DIR=$PWD
cd $PARENT_DIR

CHILD_DIRS=$(find . -maxdepth 1 -type d \( ! -name . \))

for CHILD_DIR in $CHILD_DIRS
do
	check_git_status $CHILD_DIR
done

cd $CURRENT_DIR
