#!/bin/bash

if [ ! -x "/usr/local/bin/certbot" ]; then
    pip3 --no-cache-dir install certbot
fi

if [ -n $(pgrep -f nginx) ]; then
    systemctl stop nginx
fi

/usr/local/bin/certbot certonly --standalone -d $domain -n --force-renewal --agree-tos --email $email
