#!/bin/sh

BAG=$1
TOPIC=$2
FOLDER=$(basename -s .bag $BAG)

if [ "$3" ]
then
	FOLDER=$3
fi

mkdir -p $FOLDER

NAME=$(echo $TOPIC | tr "/" "_");
echo "Extracting: $NAME";
rostopic echo -p -b $BAG $TOPIC > $FOLDER/bag$NAME.csv;
