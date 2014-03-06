#!/bin/sh

# test script for creating separate debug info
# we want to check if our new .note.gnu.source-id section
# survives this process

# create debug info file
objcopy --only-keep-debug demo demo.debug
# alternative: you keep the complete file with debug info
#cp demo demo.debug
# strip debug info from delivery
strip -g demo

