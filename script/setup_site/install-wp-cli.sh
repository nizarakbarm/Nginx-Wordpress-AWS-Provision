#!/bin/bash

if ! test -f "/usr/local/bin/composer"
then
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
    php composer-setup.php
    php -r "unlink('composer-setup.php');"

    mv composer.phar /usr/local/bin/composer
fi

if ! test -f "/usr/local/bin/wp"
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

exit 0