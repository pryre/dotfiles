#!/bin/sh

BAG_NAME=$1
FOLDER=$(basename -s .bag $BAG_NAME)

if [ "$2" ]
then
	FOLDER=$2
fi

for TOPIC in $(rostopic list -b $BAG_NAME)
do
	~/Scripts/rosbagtopic2csv.sh $BAG_NAME $TOPIC $FOLDER_NAME
done
