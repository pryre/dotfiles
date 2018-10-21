#!/bin/bash

ls -l | cut -f9,11 -d' ' > refs.txt
