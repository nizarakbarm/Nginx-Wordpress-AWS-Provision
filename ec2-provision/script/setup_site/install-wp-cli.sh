#!/bin/bash

if [ -z $(wp cli version) ]
then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    if [[ $? -ne 0 ]]; then
        echo "Warning: download wp-cli failed!"
        exit 1
    fi
    chmod 755 wp-cli.phar
    if [[ $? -ne 0 ]]; then
        echo "Warning: change permission wp-cli failed!"
        exit 1
    fi
    mv wp-cli.phar /usr/local/bin/wp
    if [[ $? -ne 0 ]]; then
        echo "Warning: change owner wp-cli failed!"
        exit 1
    fi
else
    echo "WP CLI have been installed"
fi

exit 1