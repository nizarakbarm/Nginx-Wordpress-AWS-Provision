#!/bin/bash

#set -x

LOG_INSTALL_MYSQL="/var/log/install_mysql.log"
if [ ! -f $LOG_INSTALL_MYSQL ]
then
    touch $LOG_INSTALL_MYSQL
fi

. $HOME/script/basic_single_escape.sh

sed -i "/#\$nrconf{restart} = 'i';/s/.*/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf
sed -i "/#\$nrconf{kernelhints} = -1;/s/.*/\$nrconf{kernelhints} = -1;/" /etc/needrestart/needrestart.conf
apt -o Apt::Get::Assume-Yes=true install mysql-server
if [[ $? -eq 0 ]] 
then
    echo "$(date '+%d/%b/%Y:%T') Info: Install MySQL Success" | tee -a $LOG_INSTALL_MYSQL
else
    echo "$(date '+%d/%b/%Y:%T') Warning: Install MySQL Failed" | tee -a $LOG_INSTALL_MYSQL
    exit 1
fi
sed -i "/\$nrconf{restart} = 'a';/s/.*/#\$nrconf{restart} = 'i';/" /etc/needrestart/needrestart.conf
sed -i "/\$nrconf{kernelhints} = -1;/s/.*/#\$nrconf{kernelhints} = -1;/" /etc/needrestart/needrestart.conf

systemctl enable mysql && systemctl restart mysql
if [[ ! $? -ne 0 ]]; then
    echo "Warning: restart MySQL failed!"
    exit 1
fi

if [ -z "$root_pass" ]
then
    echo "Warning: root password is not defined!"
    print_help
    exit 1
fi

# delete anonymous user
mysql -e "DELETE FROM mysql.user WHERE User='';"
if [[ $? -eq 0 ]]
then
    echo "$(date '+%d/%b/%Y:%T') Info: Delete Anonymous User Success" | tee -a $LOG_INSTALL_MYSQL
else
    echo "$(date '+%d/%b/%Y:%T') Warning: Delete Anonymous User Failed" | tee -a $LOG_INSTALL_MYSQL
    exit 1
fi
# delete remote root
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
# remove test database and it's privileges
if [ ! -z $(mysql -e "SHOW DATABASES LIKE 'test'") ]
then
    mysql -e "DROP DATABASE test;"
    if [[ $? -eq 0 ]]
    then
        echo "$(date '+%d/%b/%Y:%T') Info: DROP Database Test Success" | tee -a $LOG_INSTALL_MYSQL
    else
        echo "$(date '+%d/%b/%Y:%T') Warning: DROP Database Test Failed" | tee -a $LOG_INSTALL_MYSQL
        exit 1
    fi
    mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
    if [[ $? -eq 0 ]]
    then
        echo "$(date '+%d/%b/%Y:%T') Info: Delete Privilege of Database Test Success" | tee -a $LOG_INSTALL_MYSQL
    else
        echo "$(date '+%d/%b/%Y:%T') Warning: Delete Privilege of Database Test Failed" | tee -a $LOG_INSTALL_MYSQL
        exit 1
    fi
fi

# reload privileges
mysql -e "FLUSH PRIVILEGES;"

esc_root_pass=$(basic_single_escape "$root_pass")
# Update root password
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$esc_root_pass';"
if [[ $? -eq 0 ]]
then
    echo "$(date '+%d/%b/%Y:%T') Info: ALTER Root Password Success" | tee -a $LOG_INSTALL_MYSQL
else
    echo "$(date '+%d/%b/%Y:%T') Warning: ALTER Root Password Failed" | tee -a $LOG_INSTALL_MYSQL
    exit 1
fi