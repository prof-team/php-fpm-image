FROM php:7.0-fpm

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y \
        cron \
        python-pip \
        nano \
        htop \
        git \
        wget \
        logrotate \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libcurl4-gnutls-dev \
        libxpm-dev \
        libvpx-dev \
        libonig-dev

RUN pip install supervisor \
    && pip install superslacker

# Some basic extensions
RUN docker-php-ext-install -j$(nproc) json mbstring opcache

# Install gd
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/
RUN docker-php-ext-install gd

# Install mysql
RUN docker-php-ext-install -j$(nproc) pdo pdo_mysql mysqli

# Install pgsql
RUN apt-get install -y libpq-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo_pgsql pgsql

# Intl
RUN apt-get install -y libicu-dev
RUN docker-php-ext-install -j$(nproc) intl

# Install amqp
RUN apt-get install -y \
        librabbitmq-dev \
        libssh-dev \
    && docker-php-ext-install \
        bcmath \
        sockets \
    && pecl install amqp \
    && docker-php-ext-enable amqp

# Install Memcached
RUN apt-get install -y libmemcached-dev zlib1g-dev
RUN pecl install memcached
RUN docker-php-ext-enable memcached

# Install PECL Redis
RUN pecl install redis && docker-php-ext-enable redis

# Install APCu and APC backward compatibility
RUN pecl install apcu \
    && pecl install apcu_bc \
    && docker-php-ext-enable apcu --ini-name 10-docker-php-ext-apcu.ini \
    && docker-php-ext-enable apc --ini-name 20-docker-php-ext-apc.ini

# Install mongodb
RUN apt-get install -y \
        libssl-dev \
    && pecl install mongodb-1.9.2 \
    && docker-php-ext-enable mongodb

# Install ldap
RUN apt-get install libldap2-dev -y && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap

# Install zip
RUN apt-get install -y \
        libzip-dev \
        zip \
        unzip \
  && docker-php-ext-configure zip \
  && docker-php-ext-install zip

RUN docker-php-ext-install exif

# Install xdebub
RUN curl -L https://github.com/xdebug/xdebug/archive/2.8.1.tar.gz -o 2.8.1.tar.gz && \
        tar -xvf 2.8.1.tar.gz && \
        cd xdebug-2.8.1 && phpize && ./configure --enable-xdebug && make && make install

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- \
        --filename=composer \
        --install-dir=/usr/local/bin \
        --1

# Install composer plugins
RUN composer global require --optimize-autoloader "hirak/prestissimo" && \
    composer global dumpautoload --optimize && \
    composer clear-cache

# install php-cs-fixer
RUN curl -L https://cs.symfony.com/download/php-cs-fixer-v2.phar -o php-cs-fixer && \
    chmod a+x php-cs-fixer && \
    mv php-cs-fixer /usr/local/bin/php-cs-fixer

RUN apt-get clean && apt-get autoclean && apt-get autoremove -y
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN mkdir -p /var/log/php

ADD ./conf.d/*.ini /usr/local/etc/php/conf.d/

RUN rm /usr/local/etc/php-fpm.d/*
ADD ./php-fpm.d/www.conf /usr/local/etc/php-fpm.d/

RUN rm /usr/local/etc/php-fpm.conf.default
ADD php-fpm.conf /usr/local/etc/

RUN chown -R www-data:www-data /var/www

COPY docker-entrypoint.sh /entrypoint.sh
ADD supervisord.conf /etc/supervisor/supervisord.conf

WORKDIR /var/www
RUN rm -rf /var/www/html

ENTRYPOINT ["sh", "/entrypoint.sh"]
CMD ["php-fpm"]
