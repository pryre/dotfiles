#!/bin/sh

pikaur -S $(pacman -Qq | grep -Ee '-(bzr|cvs|darcs|git|hg|svn)$') --rebuild
