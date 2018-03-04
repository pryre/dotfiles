#!/bin/sh

if pgrep "deadbeef" > /dev/null
then
	deadbeef --play-pause
fi
