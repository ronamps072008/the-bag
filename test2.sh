#    This program is free software: you can redistribute it and/or modify 
#    it under the terms of the GNU General Public License as published by 
#    the Free Software Foundation, either version 3 of the License, or 
#    (at your option) any later version. 
# 
#    This program is distributed in the hope that it will be useful, 
#    but WITHOUT ANY WARRANTY; without even the implied warranty of 
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
#    GNU General Public License for more details. 
# 
#    You should have received a copy of the GNU General Public License 
#    along with this program.  If not, see <http://www.gnu.org/licenses/>. 

#!/bin/ksh
#******************************************************************************************************************;
# Program Name : test2.sh                                          Author :John Michael Floralde                 **;
# Location     :                                                                         **************************;
# Description  : Performs space check on specified path/s and sends                      **************************;
#--------------------------------------------------------------------------------------- **************************;
# Change Log :                                                                           **************************;
# Date        Programmer         Description                                             **************************;
#                                                                                        **************************;
#******************************************************************************************************************;
#####################################################################################################################################################################
# INITIALIZE REQUIRED VARIABLES                                                                                                                                     #
#####################################################################################################################################################################
#For additional path/s, enter new variable/s v_pathx, e.g. v_path4, v_path5 and so on.
v_path1="path1"
v_path2="path2"
v_path3="path3"
v_path_usage_header=`df -h | head -1 | tr -s " " | cut -f2,3,4,5, -d" "`
v_path_usage=`df -h $v_path | tr -s " " |cut -f1,2,3,4,5, -d" "| tail -1`
v_recipients="john-doe@mail.com"
v_path_tmp="tmppath" 

#####################################################################################################################################################################
# CREATE PATH FOR TEMPORARY FILES STORAGE                                                                                                                           #
#####################################################################################################################################################################
if [ -d "$v_path_tmp" ]; then
        cd $v_path_tmp
    else
        printf "\n$v_path_tmp not existing. Creating directory $v_path_tmp.\n"
        mkdir $v_path_tmp
        cd $v_path_tmp
fi

#####################################################################################################################################################################
# CREATE PATH.TMP THEN LOOP CODE BASED ON PATHS DECLARED                                                                                                            #
#####################################################################################################################################################################

#####For additional path/s add \n$v_pathx below, e.g. \n$v_path4\n$v_path5. ##### 
printf "$v_path1\n$v_path2\n$v_path3" > path.tmp
#################################################################################
#####Looping happens here########################################################
for path in `cat $v_path_tmp/path.tmp`
do
    v_subject="SUMMARY REPORT of Space Utilization for $path on `hostname`"
    #################################################################################################################################################################
    # CHECK IF PATH EXISTS                                                                                                                                          #
    #################################################################################################################################################################
    printf "\n Changing directory to `hostname`:$path \n"
    sleep 3
    if [ -d "$path" ]; then
        cd $path
    else
        printf "\n `hostname`:$path does not exist. \n" | mailx -s "An error was encounter while doing space check on `hostname`:$path" $v_recipients
        exit 1
    fi
    
    ################################################################################################################################################################
    # CHECK IF PATH IS EMPRTY                                                                                                                                      #
    ################################################################################################################################################################
    printf "\n Checking if $path is empty.\n"
    if [ "$(ls -A $path)" ]; 
            then sleep 1
        else 
            printf "\n$path is empty.\n" | mailx -s "An error was encounter while doing space check on `hostname`:$path" $v_recipients
            exit 1
    fi
    sleep 3
        
    ################################################################################################################################################################
    # CREATE FINAL REPORT                                                                                                                                          #
    ################################################################################################################################################################
    printf "\n Creating final report for $path.\n"
    echo "Summary of $path." >> $v_path_tmp/email_body.tmp
    echo "" >> $v_path_tmp/email_body.tmp
    printf '\ %-5s %-5s %-5s %-5s \n' $v_path_usage_header  >> $v_path_tmp/email_body.tmp
    printf '\ %-5s %-5s %-5s %-5s \n' $v_path_usage >> $v_path_tmp/email_body.tmp
    echo "" >> $v_path_tmp/email_body.tmp
    
    #Perform User Disk Space Utilization
    ls -1 | grep -v "lost+found" |grep -v "email_body.tmp" > $v_path_tmp/Users.tmp
    for user in `cat $v_path_tmp/Users.tmp | grep -v "Users.tmp"`
    do
        folder_size=`du -sh $user 2>/dev/null` # should be run using a more privileged user so that other folders can be read (2>/dev/null was used to discard error messages i.e. "du: cannot read directory `./marcnad/.gnupg': Permission denied")
        folder_date=`ls -ltr | tr -s " " | cut -f6,7,8,9, -d" " | grep -w $user | cut -f1,2,3, -d" "` 
        folder_size="$folder_size        $folder_date"
        printf '\ %-5s %-15s %-5s %-3s %-2s %-5s \n' $folder_size >> $v_path_tmp/Users_Usage.tmp 
    done
    
    echo "Summary of $path Disk Space Utilization per folder." >> $v_path_tmp/email_body.tmp
    echo "" >> $v_path_tmp/email_body.tmp
    A="SIZE"
    B="USER_FOLDER"
    C="DATE_LAST_MODIFIED"
    printf '\ %-5s %-15s %-20s \n' $A $B $C >> $v_path_tmp/email_body.tmp 
    
    for i in T G M K
    do 
        grep [0-9]$i $v_path_tmp/Users_Usage.tmp | sort -nr -k 1  >> $v_path_tmp/email_body.tmp 
    done
    
    ################################################################################################################################################################
    # SEND FINAL REPORT AND REMOVE TEMPORARY FILES                                                                                                              #
    ################################################################################################################################################################
    
    #Send a summary report email.
    printf "\n Sending summary email.\n"
    sleep 3
    chmod 775 $v_path_tmp/email_body.tmp | cat $v_path_tmp/email_body.tmp | mailx -s "$v_subject" $v_recipients
    
    printf "\n Execution of test1.sh for $path finished successfully.\n"
    
    #Remove temporary files created
    printf "\n Removing temporary files created.\n"
    sleep 3
    rm -f $v_path_tmp/email_body.tmp $v_path_tmp/Users_Usage.tmp $v_path_tmp/Users.tmp 
done

#Remove temporary directory created#
printf "\nRemoving temporary directory created. \n"
rm -rf $v_path_tmp
sleep 3
printf "\nDone.\n"
