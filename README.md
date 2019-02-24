# php-fpm docker

1. Pull image from [docker hub](https://hub.docker.com/r/profteam/php-fpm/)

`docker pull profteam/php-fpm`

2. Now you can run image

docker run -it profteam/php-fpm bash

## Environment Variables
```
FPM_MAX_CHILDREN: 5
FPM_START_SERVERS: 2
FPM_MIN_SPARE_SERVERS: 1
FPM_MAX_SPARE_SERVERS: 3
FPM_MAX_REQUESTS: 500
FPM_ACCESS_LOG_STATUS: 1
FPM_SLOWLOG_TIMEOUT: 10s
INI_OPCACHE_STATUS: 0
INI_UPLOAD_MAX_SIZE: 100M
INI_MEMORY_LIMIT: 256M
INI_DISPLAY_ERRORS: 'On' OR 'Off'
INI_MAX_EXECUTION_TIME: 60 in seconds
```

## Example docker-compose.yml 
```
version: '3'

services:
  php:
    image: profteam/php-fpm:7.3
    container_name: php
    cap_add:
      - SYS_PTRACE
    environment:
      FPM_MAX_CHILDREN: 5
      FPM_START_SERVERS: 2
      FPM_MIN_SPARE_SERVERS: 1
      FPM_MAX_SPARE_SERVERS: 3
      FPM_MAX_REQUESTS: 500
      FPM_ACCESS_LOG_STATUS: 1
      FPM_SLOWLOG_TIMEOUT: 10s
      INI_OPCACHE_STATUS: 0
      INI_UPLOAD_MAX_SIZE: 100M
      INI_MEMORY_LIMIT: 256M
      INI_DISPLAY_ERRORS: 'On'
      INI_MAX_EXECUTION_TIME: 60
    volumes:
      - .:/var/www
      - ./log/php:/var/log/php
```