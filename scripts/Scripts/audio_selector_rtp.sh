#!/bin/sh

pactl load-module module-null-sink sink_name=rtp format=s16be channels=2 rate=44100
pactl load-module module-rtp-send source=rtp.monitor destination=10.0.0.1 port=5004
