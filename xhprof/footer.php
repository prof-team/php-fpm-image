<?php

$host = !empty($_SERVER['HTTP_HOST']) ? $_SERVER['HTTP_HOST'] : '';

if (extension_loaded('xhprof') && strpos($host, 'prof') === false) {
    $profilerNamespace = !empty($_SERVER['REQUEST_URI']) ? str_replace('/', '_', ltrim($_SERVER['REQUEST_URI'], '/'))  :  '-';
    $xhprofData = xhprof_disable();
    $xhprofRuns = new XHProfRuns_Default();
    $runId = $xhprofRuns->save_run($xhprofData, $profilerNamespace);
}