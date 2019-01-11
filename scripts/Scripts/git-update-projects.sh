
#!/bin/bash

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

export -f check_git_update

PARENT_DIR="."

if [ ! -z $1 ]
then
	PARENT_DIR=$1
fi

CURRENT_DIR=$PWD
cd $PARENT_DIR

find -L . -maxdepth 1 -type d \( ! -name . \) | xargs -n 1 -P 16 -I {} bash -c 'check_git_update "$@"' _ {}

cd $CURRENT_DIR
