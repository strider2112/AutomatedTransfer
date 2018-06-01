#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "$DIR"/filetransfer.conf

eval "$(ssh-agent -s)"
ssh-add "$sshKeyFile"

clear

# temporary log setup
templog=$(mktemp -t templog.XXXX)
templogfind=$(mktemp -t templogfind.XXXX)

# Array for rsync Variables, add more if necessary
declare -a syncvar=('-avzPL' '-e' 'ssh' "--log-file=$templog" "$ratelimit")

# Configures the log file in the logfolder.
dateStamp=$(date +"%Y-%m(%b)")
logfile="$logfolder""logfile_""$dateStamp"".log"
tempmail=".tempmail"
numberOfLogFiles=$(($(find "$logfolder" -maxdepth 1 ! -iname ".*" | wc -l) - 1))

# clean out the log folder if there are more than 30 logs
if [ "$numberOfLogFiles" -eq 1 ]; then
	echo "There is $numberOfLogFiles log file"
else
	echo "There are $numberOfLogFiles log files"
fi

if [ "$numberOfLogFiles" -gt 12 ]; then
	echo "Deleting log files as there are more than 12 (months of the year)"
	rm $logfolder*
fi

# If a log file exists for today, use it, if not create one and set permissions
if [ -e "$logfile" ]; then
	echo "Logfile for today exists at: $logfile"
else
	echo "Created new log file at: $logfile"
	touch "$logfile"
fi
chmod 666 "$logfile"

# Create the start of the file here, it will be saved to a temporary file
printf "\t\t~~ START OF LOG ~~\n\nDATE: %s, TIME: %s" "$(date +%b-%d-%Y)" "$(date +%r)" >> $tempmail


# Mail out an error report when called by a general signal trap
    cleanfail () {
    printf "Whatbox synchronisation has failed due to unspecified signal error.\n\n" >> $tempmail
    cat $tempmail >> "$logfile"
    rm $tempmail
    rm "$templog"
    rm "$templogfind"
    exit 1
    }

# Mail out an error report when called by an rsync trap.
    cleanfail_rsync () {
    printf "Whatbox rsync has failed. Rsync log attached.\n\n" >> $tempmail
    cat "$templog" >> $tempmail
    cat $tempmail >> "$logfile"
    rm $tempmail
    rm "$templog"
    rm "$templogfind"
    exit 1
    }

# Mail out an error report when called by a find trap.
    cleanfail_find () {
    printf "Whatbox symbolic link cleanup has failed. Find process log attached.\n\n" >> $tempmail
    cat "$templogfind" >> $tempmail
    cat "$tempmail" >> "$logfile"
    rm $tempmail
    rm "$templog"
    rm "$templogfind"
    exit 1
    }

# Mail out an error report when called by an existing instance of rsync already running trap.
    cleanfail_rsync_active () {
    printf "rsync process is still active. Large download may still be in progress.\n\n" >> $tempmail
    cat $tempmail >> "$logfile"
    rm $tempmail
    rm "$templog"
    rm "$templogfind"
    exit 1
    }

# Check if rsync is already running. If so, exit with an email notification reporting transfers still in progress.
pgrep rsync >/dev/null 2>&1 && cleanfail_rsync_active

# Touch timestamp file to prevent deleting links that are created while rsync is running
ssh $remoteuser@$remoteserver touch $sourcefolder/.rsync-timestamp

# Trap error signals
trap cleanfail 1 2 3 15

# If all is well so far, commence the rsync automated download from the seedbox.
rsync "${syncvar[@]}" $remoteuser@$remoteserver:$sourcefolder $targetfolder

# Trap any errors, log and email them if rsync does not terminate with a successful exit value (0). Otherwise, continue to delete symlinks now that we're done with them. If the deletion of symlinks fails, this error is also trapped, logged and emailed.
if [ $? != 0 ]; then
    cleanfail_rsync
else
    printf "\n\nTransfer successful. Deleted following symbolic links:\n\n" >> "$templogfind"
    ssh $remoteuser@$remoteserver find $sourcefolder \! -newer $sourcefolder/.rsync-timestamp -type l -delete -print >> "$templogfind"
    if [ $? != 0 ]; then
        cleanfail_find
    else
    :
    fi
fi

# Add the symlink deletion results
cat "$templogfind" >> $tempmail

# add end of log to the end of the log file before it is saved
printf "\n\t\t~~ END OF LOG ~~ \n\n" >> $tempmail

# Log the compiled report
cat $tempmail >> "$logfile"
rm "$templog"
rm "$templogfind"
rm $tempmail

# Call the MoveFiles script after this to sort the files
"$DIR"/MoveFiles.sh

exit 0
