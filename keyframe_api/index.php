<?php
// ============================================================
// KEYFRAME API — Main Router
// Run: php -S localhost:8000 -t keyframe_api
// ============================================================

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Parse URI
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$uri = explode('/', trim($uri, '/'));

// Remove 'api' prefix
if (isset($uri[0]) && $uri[0] === 'api') {
    array_shift($uri);
}

$resource = $uri[0] ?? '';
$method = $_SERVER['REQUEST_METHOD'];

// Route to handlers
switch ($resource) {
    case 'auth':
        require_once __DIR__ . '/api/auth.php';
        break;
    case 'products':
        require_once __DIR__ . '/api/products.php';
        break;
    case 'categories':
        require_once __DIR__ . '/api/categories.php';
        break;
    case 'cart':
        require_once __DIR__ . '/api/cart.php';
        break;
    case 'orders':
        require_once __DIR__ . '/api/orders.php';
        break;
    case 'users':
        require_once __DIR__ . '/api/users.php';
        break;
    case 'notifications':
        require_once __DIR__ . '/api/notifications.php';
        break;
    case 'feedback':
        require_once __DIR__ . '/api/feedback.php';
        break;
    case 'issues':
        require_once __DIR__ . '/api/issues.php';
        break;
    case 'wishlist':
        require_once __DIR__ . '/api/wishlist.php';
        break;
    case 'debug':
        require_once __DIR__ . '/api/debug.php';
        break;
    case 'payments':
        require_once __DIR__ . '/api/payments.php';
        break;
    default:
        http_response_code(404);
        echo json_encode(["error" => "Endpoint not found", "uri" => $_SERVER['REQUEST_URI']]);
        break;
}
?>
