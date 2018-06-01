#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "$DIR"/filetransfer.conf

# Update symbolic links
cp -sR "$linkFromLocationMovies" "$linkToLocationMoves"
cp -sR "$linkFromLocationTV" "$linkToLocationTV"

clear
