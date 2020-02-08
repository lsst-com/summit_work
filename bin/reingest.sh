#!/bin/bash

if [ "$1" == "-h" -o "$1" == "--help" ]; then
    echo "$0 [-r] SRCREPO DESTDIR"
    echo "Reingests all raw FITS files in SRCREPO into DESTDIR as symlinks."
    echo "Creates DESTDIR and a _mapper file and registry if necessary."
    echo "Can be run multiple times; ignores previously-ingested files."
    echo "Run linkfix.sh afterwards to normalize the resulting symlinks."
    echo "With -r, only creates/adds to the new registry; does no linking."
    echo "Using -r is dangerous if the pathname templates have changed."
    exit 0
fi
mode=link
if [ "$1" == "-r" ]; then
    mode=skip
    shift
fi
[ -d "$2" ] || mkdir "$2"

if [ -d "$1/raw" -a -f "$1/registry.sqlite3" ]; then
    raw="$1/raw"
    [ -f "$2/_mapper" ] || cp "$1/_mapper" "$2/_mapper"
elif [ -d "$1/_parent/raw" -a -f "$1/_parent/registry.sqlite3" ]; then
    raw="$1/_parent/raw"
    [ -f "$2/_mapper" ] || cp "$1/_parent/_mapper" "$2/_mapper"
else
    echo "$1 does not appear to be a raw-containing repo"
    exit 1
fi

echo "$raw reingesting into $2"

find $raw -name '*.fits' -print \
    | xargs ingestImages.py "$2" \
        --mode $mode --config allowError=True --ignore-ingested
