#!/bin/sh

ls -l | grep -e '->' | cut -f9,11 -d' ' > refs.txt
