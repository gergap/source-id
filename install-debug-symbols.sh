#!/bin/bash
# Installs the debug symbols into a symbol directory
# using the build-id structure

# your symbol directory
# Tip: you can put this onto a NFS server so that new debug
# symbols are available for all developers in your network.
SYMBOLDIR="~/symbols"
# product name
PRODUCT="demo"
# product version
VERSION="1.0.0"
# debug info to install
DEBUGINFO=./demo.debug

# ensure that the path exists
mkdir -p $SYMBOLDIR/.build-id || exit 1

# compute install path
INSTALLPATH="$SYMBOLDIR/$PRODUCT/$VERSION"
# compute full install filename
FILENAME="$INSTALLPATH/$(basename $DEBUGINFO)"

# create product structure (just an example, this path is not important)
mkdir -p "$INSTALLPATH" || exit 1
# install your debug info
cp $DEBUGINFO $INSTALLPATH

# create a link inside .build-id (this is path is important and must follow
# the build-id rules. See https://sourceware.org/gdb/onlinedocs/gdb/
# Separate-Debug-Files.html.
BUILD_ID=`readelf -n demo.debug | grep "Build ID:" | sed -e 's/.*\([a-f0-9]\{40\}\).*/\1/g'`
FOLDER=${BUILD_ID:0:2}
LINKNAME=${BUILD_ID:2:38}

# create folder with 1st two digits of build-id
mkdir -p $SYMBOLDIR/.build-id/$FOLDER || exit 1
# create symlink inside this folder with rest of build-id
ln -s "${FILENAME}" "$SYMBOLDIR/.build-id/$FOLDER/$LINKNAME" || exit 1

echo "installed $DEBUGINFO into ${FILENAME}"
echo "created symlink $SYMBOLDIR/.build-id/$FOLDER/$LINKNAME -> $FILENAME"
