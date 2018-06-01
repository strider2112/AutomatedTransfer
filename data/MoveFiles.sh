#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "$DIR"/filetransfer.conf

# This calls the extract command first, to extract any rars
# set the download folder here if a new MediaDrive is added
"$DIR"/UnrarFiles.sh --clean=rar --full-path --output "$targetfolder" "$targetfolder"

# Calls the binary sorttv.pl
nice "$perlinstallation" "$sorttvinstallation" --directory-to-sort="$directorytosort" --movie-directory="$moviedirectory" --tv-directory="$tvdirectory"

# Update symbolic links
if [ "$useSymbolicLinking" eq "yes" ]; then
	"$DIR"/UpdateLinks.sh
fi
