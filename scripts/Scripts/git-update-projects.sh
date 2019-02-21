#!/bin/sh

check_git_update() {
	START_DIR="$(pwd)"
	cd $1

	REPO_STATUS="$(git fetch 2>&1)"

	if [ "$REPO_STATUS" ]
	then
		MERGE_STATUS="$(git merge --ff-only 2>&1)"

		TITLE="$(tput bold)$(basename $(pwd))$(tput sgr0)"
		printf "$TITLE\n$REPO_STATUS\n$MERGE_STATUS\n---\n"
	fi

	cd "$START_DIR"
}

PARENT_DIR="."

if [ $1 ]
then
	PARENT_DIR=$1
fi

CURRENT_DIR=$PWD
cd $PARENT_DIR
#find -L . -maxdepth 1 -type d \( ! -name . \) | xargs -n 1 -P 16 -I {} bash -c 'check_git_update "$@"' _ {}
CHILD_DIRS=$(find . -maxdepth 1 -type d \( ! -name . \))

MAX_CHILDREN=16
CUR_CHILDREN=0

for CHILD_DIR in $CHILD_DIRS
do
	#echo Checking $CHILD_DIR
	check_git_update $CHILD_DIR &

	#Do some lazy-mans checking to make sure we don't make too many processes
	CUR_CHILDREN=$(($CUR_CHILDREN + 1))

	if [ $CUR_CHILDREN -ge $MAX_CHILDREN ]
	then
		#echo "Max process reached, waiting before spawning more"
		wait
		CUR_CHILDREN=0
	fi
done

wait

cd $CURRENT_DIR
