#!/usr/bin/env bash

docker build --pull --no-cache -t profteam/php-fpm:7.1 .
#docker build --pull -t profteam/php-fpm:7.1 .