#!/bin/sh

if [ "$#" -eq 1 ]
then
	API_PATH=$(echo $1 | sed -e 's|github.com|api.github.com/repos|' -e 's|http:|https:|')
	echo "Checking: $API_PATH"
	API_TEXT=$(curl $API_PATH | grep size)
	API_NUM=$(echo $API_TEXT | sed 's|[^0-9]||g')

	if [ "$API_NUM" -lt 1000 ]
	then
		echo "$API_NUM kB"
	else
		API_MB=$(($API_NUM / 1000))
		echo""
		echo "Repo Size: $API_MB.$(($API_NUM - ($API_MB*1000))) MB"
	fi
else
	echo "Usage: gitCheckSize.sh https://github.com/user/repo"
fi
