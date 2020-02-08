#!/bin/bash

if [ "$1" == "-h" -o "$1" == "--help" ]; then
    echo "$0 [-l] REPO"
    echo "Normalizes the symlinks in the raw subdirectory of the repo"
    echo "by linking to the ultimate destination."
    echo "With -l, uses hard links instead of symlinks, allowing the"
    echo "originals to be removed if desired.  The repo and the ultimate"
    echo "destination must be on the same filesystem to use this option."
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
        if [ -L "$src" -o -z "$symlink" ]; then
            while [ -L "$src" ]; do
                src=`readlink "$src"`
            done
            ln $symlink "$src" "$link"-tmp || (
                echo "Unable to create link from $src to $link"
                [ -z "$symlink" ] && echo "Both must be on the same filesystem"
            ) && exit 1
            rm "$link"
            mv "$link"-tmp $link
        fi
    done
