# test2.sh

#Description
This script performs space check using df -h and du -sh commands, then sends summary email on recipients.

#Configuration
Update the v_path parameter with the paths to be checked.

Update v_recipients parameter with the email report recipients.

Update v_path_tmp parameter with the path for creating temporary files. Must have permission to write on this directory.

#Usage
Can be used to monitor space of directories in conjuction with cronjob.
