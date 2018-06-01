#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "$DIR"/filetransfer.conf

# Update symbolic links, the * is needed to do the files inside the directories
cp -sR "$linkFromLocationMovies"* "$linkToLocationMoves"
cp -sR "$linkFromLocationTV"* "$linkToLocationTV"

clear

exit 0
