FROM node:lts-alpine AS node
WORKDIR /var/www/
COPY . .
RUN apk add --no-cache --virtual .build-deps autoconf automake build-base bash libjpeg-turbo-dev libpng-dev libtool pkgconf nasm && \
    npm ci && \
    npm rb && \
    npm run prod && \
    apk del .build-deps

FROM php:7.3-fpm-alpine
WORKDIR /var/www/
COPY . .
COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY --from=node /var/www/ .

RUN apk add --no-cache --virtual .run-deps nginx postgresql-dev libzip-dev libpng-dev && \
    docker-php-ext-install pdo pdo_pgsql zip gd && \
    mkdir -p bootstrap/cache/ && \
    mkdir -p storage/logs/ && \
    mkdir -p storage/framework/sessions/ && \
    mkdir -p storage/framework/views/ && \
    mkdir -p storage/framework/cache/ && \
    mkdir -p /run/nginx/ && \
    chmod -R ug+rwx storage bootstrap/cache && \
    composer install && \
    chown -R www-data:www-data . && \
    chmod -R ugo+rwX . && \
    chmod +x start.sh

RUN rm /etc/nginx/conf.d/default.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY php-fpm/www.conf /etc/php7/php-fpm.d/www.conf
EXPOSE 80
CMD ["./start.sh"]

