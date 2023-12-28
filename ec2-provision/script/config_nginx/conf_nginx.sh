#!/bin/bash

print_help() {
    echo ""
    echo "Setup WP"
    echo "Usage: $PROGNAME [-s|--setup-vhost <domain_name> ]"
    echo ""
}
while test -n "$1"; do
    case "$1" in
        --help)
            print_help
            exit 0
            ;;
        -h)
            print_help
            exit 0
            ;;
        --setup-vhost)
            DOMAIN_NAME=$2
            shift
            ;;
        -s)
            DOMAIN_NAME=$2
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            print_help
            exit 1
            ;;
    esac
    shift
done


. ./all_params_file.sh

. ./map_webp_conf.sh

. ./diffie_helman.sh
. ./security_conf.sh

. ./fastcgi_cache_conf.sh

if [ -n "$DOMAIN_NAME" ]; then
    ./vhost_congf.sh -d "$DOMAIN_NAME"
fi

. ./nginx_main_conf.sh

nginx_test=$(nginx -t 2>&1)
if [[ $nginx_test =~ ok || $nginx_test =~ successful ]]; then
    echo "Info: The configuration is ok and Nginx test successful"
    # After know that test successfull, activate vhost
    systemctl restart nginx
    if [[ ! $? -ne 0 ]]; then
        echo "Warning: restart NGINX failed!"
        exit 1
    fi
fi
else
    echo "Error: configuration error and nginx test is not successful! Check configuration again"
    exit 1
fi

exit 0