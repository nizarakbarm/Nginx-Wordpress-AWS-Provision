#!/bin/bash

. ./nginx.preinst

. ./compile_nginx

if [ -n $(nginx -V 2>&1) ]; then
. ./configure_systemd_nginx.sh
. ./nginx.postinst
  if [ -n $(pgrep -f nginx) ]; then
    pkill -9 -f nginx
    systemctl daemon-reload
    systemctl enable nginx && systemctl start nginx
    if [[ ! $? -ne 0 ]]; then
      echo "Warning: restart NGINX failed!"
    exit 1
fi
  else
    systemctl daemon-reload
    systemctl enable nginx && systemctl start nginx
    if [[ ! $? -ne 0 ]]; then
      echo "Warning: restart NGINX failed!"
      exit 1
    fi
fi
  fi
else
    echo "Error: binary nginx not found and  nginx compilation failed!"
    exit 1
fi

exit 0