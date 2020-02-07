#!/bin/bash

if [ "$1" == "-h" -o "$1" == "--help" ]; then
    echo "$0 [-l] REPO"
    echo "Normalizes the symlinks in the raw subdirectory of the repo"
    echo "by linking to the ultimate destination."
    echo "With -l, uses hard links instead of symlinks, allowing the"
    echo "originals to be removed if desired."
    exit 0
fi
symlink="-s"
if [ "$1" == "-l" ]; then
    symlink=""
    shift
fi

find "$1/raw" -type l -print | \
    while read link; do
        src=`readlink "$link"`
        while [ -L "$src" ]; do
            src=`readlink "$src"`
        done
        rm "$link"
        ln $symlink "$src" "$link"
    done
