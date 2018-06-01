AutomatedTransfer Version 1.0

DISCLAIMER: This software uses external programs, available from sources like Github.com,
to perform some of the operations described. The author of TransferFiles does not endorse,
nor did they code, participate in, or write these software binaries.

Usage: This software is intended to automate the process of transfering multimedia
files between a remote server and a local server. Using Rsync, it will collect data 
from the remote location and copy it to the local location, then it will extract and
sort these files into specified locations.

Setup: 
1. Install rsync on your local machine, google "How to get rsync on [my system]".
	Usually, it's something like 'sudo apt install rsync'
2. Ensure ssh is configured and working properly, you need to be able to ssh into your remote machine.
	This script requires passwordless RSA authentication with your SSH server
3. Install the perl script SortTV. Can be found at https://github.com/farfromrefug/sorttv
	(credit goes to farfromrefug for this script and its use)
4. Install perl if it isn't already on your system. Google "How to get perl on [my system]".
	Usually, it's something like 'sudo apt install perl'
5. Modify the values in './data/filetransfer.conf' for your specific setup.
	This contains information like your download to location, and sort locations

Using the Scripts:
1. Make sure the script FileTransfer is set to executable (chmod +x FileTransfer)
2. Run it by typing ./FileTransfer, or make a symbolic link to a directory in your PATH variable

Typing FileTransfer -h|--help will show this page.
