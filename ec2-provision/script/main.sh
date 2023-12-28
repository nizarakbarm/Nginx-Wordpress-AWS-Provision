#!/bin/bash

if [ -z "$USERNAME_DB" ]; then
    echo "Warning: USERNAME_DB is not defined!"
    exit 1
fi

if [ -z "$DB_NAME" ]; then
    echo "Warning: DB_NAME is not defined!"
    exit 1
fi

if [ -z "$USERNAME" ]; then
    echo "Warning: USERNAME is not defined!"
    exit 1
fi

if [ -z "$PASSWORD" ]; then
    echo "Warning: PASSWORD is not defined!"
    exit 1
fi

if [ -z "$EMAIL" ]; then
    echo "Warning: EMAIL is not defined!"
    exit 1
fi

if [ -z "$TITLE" ]; then
    echo "Warning: TITLE is not defined!"
    exit 1
fi

if [ -z "$DOMAIN_NAME" ]; then
    echo "Warning: $DOMAIN_NAME is not defined!"
    exit 1
fi

./ubuntu-22-04-cis-hardening/entrypoint.sh

./install_nginx/install_nginx.sh
if [[ $? -ne 0 ]]; then
    echo "Warning: Install NGINX Failed!"
    exit 1
fi

./mysql_and_php_dependencies/mysql_and_php.sh -u $USERNAME -p $PASSWORD
if [[ $? -ne 0 ]]; then
    echo "Warning: Setup MySQL and PHP failed!"
    exit 1
fi

#install wp cli
./setup_site/install_wp-cli.sh
if [[ $? -ne 0 ]]; then
    echo "Warning: install wp-cli failed!"
    exit 1
fi

./setup_site/setup-wp.sh -d "$DOMAIN_NAME" --url "https://$DOMAIN_NAME" -ud "$USERNAME_DB" -pd  -db "$DB_NAME" -t "My Blog" -u "$USERNAME" -p "$PASSWORD" -e "$EMAIL"
if [[ $? -ne 0 ]]; then
    echo "Warning: Setup WP failed!"
    exit 1
fi

./config_nginx/conf_nginx.sh -s $DOMAIN_NAME
if [[ $? -ne 0 ]]; then
    echo "Warning: Setup NGINX failed!"
    exit 1
fi
./conf_php_fpm/setup_pool_conf.sh $DOMAIN_NAME
if [[ $? -ne 0 ]]; then
    echo "Warning: Setup php-fpm failed!"
    exit 1
fi

exit 0