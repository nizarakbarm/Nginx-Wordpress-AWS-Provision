#!/bin/bash

#set -x

LOG_SETUP_DATABASE="/var/log/log_setup_mysql.log"
if [ ! -f $LOG_SETUP_DATABASE ]
then
    touch $LOG_SETUP_DATABASE
fi

. $HOME/script/basic_single_escape.sh


root_pass=$(basic_single_escape $root_pass)
echo -e "[mysql]\nuser=root\npassword='"$root_pass"'" > ~/.my.cnf

username=$(basic_single_escape $username)
password=$(basic_single_escape $password)
database_name=$(basic_single_escape $database_name)
# Create username and database
mysql -u root -e "CREATE DATABASE $database_name;"
if [[ $? -eq 0 ]]
then
    echo "$(date '+%d/%b/%Y:%T') Info: Create Database Success" | tee -a $LOG_SETUP_DATABASE
else
    echo "$(date '+%d/%b/%Y:%T') Warning: Create Database Failed" | tee -a $LOG_SETUP_DATABASE
    exit 1
fi
mysql -u root -e "CREATE USER '$username'@'localhost' IDENTIFIED BY '$password';"
if [[ $? -eq 0 ]]
then
    echo "$(date '+%d/%b/%Y:%T') Info: Create Username Success" | tee -a $LOG_SETUP_DATABASE
else
    echo "$(date '+%d/%b/%Y:%T') Warning: Create Username Failed" | tee -a $LOG_SETUP_DATABASE
    exit 1
fi
mysql -u root -e "GRANT ALL PRIVILEGES ON $database_name.* TO '$username'@'localhost';"
if [[ $? -eq 0 ]]
then
    echo "$(date '+%d/%b/%Y:%T') Info: Grant Privileges Success" | tee -a $LOG_SETUP_DATABASE
    exit 1
else
    echo "$(date '+%d/%b/%Y:%T') Warning: Grant Privileges Failed" | tee -a $LOG_SETUP_DATABASE
    exit 1
fi
mysql -u root -e "FLUSH PRIVILEGES;"

# Delete ~/.my.cnf
rm -f ~/.my.cnf

