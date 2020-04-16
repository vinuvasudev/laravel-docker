#!/bin/sh
php artisan config:cache
php artisan route:cache
php artisan queue:work
crond -b
nginx -qt && nginx -g "daemon off;" >/dev/stdout 2>/dev/stderr &
php-fpm --nodaemonize --fpm-config /etc/php7/php-fpm.d/www.conf >/dev/stdout 2>/dev/stderr &
wait

