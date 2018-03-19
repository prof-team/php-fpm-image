FROM php:7.2-fpm

RUN apt-get update

RUN apt-get install -y \
        logrotate \
        nano \
        git \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev

RUN pecl install mcrypt-1.0.1
RUN docker-php-ext-enable mcrypt

RUN docker-php-ext-install -j$(nproc) iconv
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install -j$(nproc) gd

# Some basic extensions
RUN docker-php-ext-install -j$(nproc) json mbstring opcache pdo pdo_mysql pdo_pgsql mysqli

# Intl
RUN apt-get install -y libicu-dev
RUN docker-php-ext-install -j$(nproc) intl

# Install bcmath
RUN docker-php-ext-install bcmath

# Install Memcached
RUN apt-get install -y libmemcached-dev zlib1g-dev
RUN pecl install memcached
RUN docker-php-ext-enable memcached

# Install APCu and APC backward compatibility
RUN pecl install apcu \
    && pecl install apcu_bc-1.0.3 \
    && docker-php-ext-enable apcu --ini-name 10-docker-php-ext-apcu.ini \
    && docker-php-ext-enable apc --ini-name 20-docker-php-ext-apc.ini

# Install mongo
RUN apt-get update && apt-get install -y \
        libssl-dev \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb

# Install ldap
RUN apt-get install libldap2-dev -y && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap

# Install zip
RUN apt-get install -y zlib1g-dev && docker-php-ext-install zip

RUN docker-php-ext-install exif

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
# parallel install plugin
RUN composer global require hirak/prestissimo
# yii2 plugin
RUN composer global require "fxp/composer-asset-plugin:^1.3.1" --no-plugins;

# install xhprof
RUN rm -rf /var/xhprof && \
    mkdir /var/xhprof && \
    cd /var/xhprof && \
    git clone https://github.com/RustJason/xhprof . && \
    git checkout php7 && \
    cd extension && \
    phpize && \
    ./configure --with-php-config=/usr/local/bin/php-config && \
    make && \
    make install
COPY ./xhprof/*.php /var/xhprof/
VOLUME /var/xhprof

RUN apt-get clean && apt-get autoclean && apt-get autoremove -y
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN rm -rf /var/www/html
RUN mkdir /var/tmp/xhprof && chmod 777 /var/tmp/xhprof
RUN mkdir -p /var/log/php

ADD ./conf.d/*.ini /usr/local/etc/php/conf.d/
ADD ./php-fpm.d/www.conf /usr/local/etc/php-fpm.d/
ADD php-fpm.conf /usr/local/etc/

ADD ./logrotate/php /etc/logrotate.d/php

RUN chown -R www-data:www-data /var/www

WORKDIR /var/www