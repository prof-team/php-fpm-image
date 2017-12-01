<?php

$host = !empty($_SERVER['HTTP_HOST']) ? $_SERVER['HTTP_HOST'] : '';

if (extension_loaded('xhprof') && strpos($host, 'prof') === false) {
    include_once '/var/xhprof/xhprof_lib/utils/xhprof_lib.php';
    include_once '/var/xhprof/xhprof_lib/utils/xhprof_runs.php';

    xhprof_enable(XHPROF_FLAGS_CPU + XHPROF_FLAGS_MEMORY);
}