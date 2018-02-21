#!/usr/bin/bash

watch -n5 'sudo kill -USR1 $(pgrep ^dd)'
