#!/bin/bash
# This overwrites default nginx vhost file.
# Nginx gets confused when one is present and not used.
echo "" > /etc/nginx/conf.d/vhost.conf
# Remove default http settings
rm -f /etc/nginx/conf.d/default.conf
nginx
