<?php
// Router script for PHP's built-in development server.
// Usage: php -S localhost:8000 -t keyframe_api keyframe_api/router.php
//
// This file tells the built-in server to route all
// non-file requests through index.php.

$uri = $_SERVER['REQUEST_URI'];
$path = parse_url($uri, PHP_URL_PATH);
$file = __DIR__ . $path;

// If the request is for an actual file, serve it directly
if ($path !== '/' && file_exists($file) && is_file($file)) {
    return false; // Let PHP serve the file
}

// Otherwise, route through index.php
require __DIR__ . '/index.php';
?>
