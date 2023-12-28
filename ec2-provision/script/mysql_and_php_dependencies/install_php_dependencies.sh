#!/bin/bash

sed -i "/#\$nrconf{restart} = 'i';/s/.*/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf
sed -i "/#\$nrconf{kernelhints} = -1;/s/.*/\$nrconf{kernelhints} = -1;/" /etc/needrestart/needrestart.conf
apt -o Apt::Get::Assume-Yes=true install php8.1 php8.1-{curl,common,igbinary,imagick,intl,mbstring,mysql,xml,zip,apcu,memcache,opcache,redis,bcmath,fpm}
if [[ $? -eq 0 ]] 
then
    echo "$(date '+%d/%b/%Y:%T') Info: Install PHP Success"
else
    echo "$(date '+%d/%b/%Y:%T') Warning: Install PHP Failed"
    exit 1
fi
sed -i "/\$nrconf{restart} = 'a';/s/.*/#\$nrconf{restart} = 'i';/" /etc/needrestart/needrestart.conf
sed -i "/\$nrconf{kernelhints} = -1;/s/.*/#\$nrconf{kernelhints} = -1;/" /etc/needrestart/needrestart.conf