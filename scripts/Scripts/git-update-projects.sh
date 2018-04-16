#!/bin/sh

PARENT_DIR="."

if [ ! -z $1 ]
then
        PARENT_DIR=$1
fi

CURRENT_DIR=$PWD
cd $PARENT_DIR

find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "cd '{}' && pwd && git pull && echo ''" \;

cd $CURRENT_DIR
