#!/bin/bash
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

# setup FPM configs
if [ -n "$FPM_MAX_CHILDREN" ]; then
    sed -i "s/pm.max_children.*/pm.max_children = $FPM_MAX_CHILDREN/" /usr/local/etc/php-fpm.d/www.conf
fi
if [ -n "$FPM_START_SERVERS" ]; then
    sed -i "s/pm.start_servers.*/pm.start_servers = $FPM_START_SERVERS/" /usr/local/etc/php-fpm.d/www.conf
fi
if [ -n "$FPM_MIN_SPARE_SERVERS" ]; then
    sed -i "s/pm.min_spare_servers.*/pm.min_spare_servers = $FPM_MIN_SPARE_SERVERS/" /usr/local/etc/php-fpm.d/www.conf
fi
if [ -n "$FPM_MAX_SPARE_SERVERS" ]; then
    sed -i "s/pm.max_spare_servers.*/pm.max_spare_servers = $FPM_MAX_SPARE_SERVERS/" /usr/local/etc/php-fpm.d/www.conf
fi
if [ -n "$FPM_MAX_REQUESTS" ]; then
    sed -i "s/pm.max_requests.*/pm.max_requests = $FPM_MAX_REQUESTS/" /usr/local/etc/php-fpm.d/www.conf
fi
if [ -n "$FPM_ACCESS_LOG_STATUS" ] && [ "$FPM_ACCESS_LOG_STATUS" = "1" ]; then
    sed -i "s/;access.log.*/access.log = \/var\/log\/php\/fpm.access.log/" /usr/local/etc/php-fpm.d/www.conf
fi
if [ -n "$FPM_SLOWLOG_TIMEOUT" ]; then
    sed -i "s/request_slowlog_timeout.*/request_slowlog_timeout = $FPM_SLOWLOG_TIMEOUT/" /usr/local/etc/php-fpm.d/www.conf
fi

# setup INI configs
if [ -n "$INI_OPCACHE_STATUS" ]; then
    sed -i "s/opcache\.enable.*/opcache\.enable=$INI_OPCACHE_STATUS/" /usr/local/etc/php/conf.d/opcache.ini
    sed -i "s/opcache\.enable_cli.*/opcache\.enable_cli=$INI_OPCACHE_STATUS/" /usr/local/etc/php/conf.d/opcache.ini
fi
if [ -n "$INI_UPLOAD_MAX_SIZE" ]; then
    sed -i "s/post_max_size.*/post_max_size=$INI_UPLOAD_MAX_SIZE/" /usr/local/etc/php/conf.d/upload.ini
    sed -i "s/upload_max_filesize.*/upload_max_filesize=$INI_UPLOAD_MAX_SIZE/" /usr/local/etc/php/conf.d/upload.ini
fi
if [ -n "$INI_MEMORY_LIMIT" ]; then
    sed -i "s/memory_limit.*/memory_limit=$INI_MEMORY_LIMIT/" /usr/local/etc/php/conf.d/common.ini
fi
if [ -n "$INI_DISPLAY_ERRORS" ]; then
    sed -i "s/display_errors.*/display_errors=$INI_DISPLAY_ERRORS/" /usr/local/etc/php/conf.d/error.ini
    sed -i "s/display_startup_errors.*/display_startup_errors=$INI_DISPLAY_ERRORS/" /usr/local/etc/php/conf.d/error.ini
fi
if [ -n "$INI_MAX_EXECUTION_TIME" ]; then
    sed -i "s/max_execution_time.*/max_execution_time=$INI_MAX_EXECUTION_TIME/" /usr/local/etc/php/conf.d/common.ini
    sed -i "s/request_terminate_timeout.*/request_terminate_timeout = $INI_MAX_EXECUTION_TIME/" /usr/local/etc/php-fpm.d/www.conf
fi

# Disable xdebug
if [ -z "$XDEBUG_CONFIG" ]; then
    rm -f /usr/local/etc/php/conf.d/xdebug.ini
fi

if [ -f /custom-entrypoint.sh ]; then
    bash /custom-entrypoint.sh
fi

exec "$@"
