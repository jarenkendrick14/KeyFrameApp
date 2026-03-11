<?php
// ============================================================
// WISHLIST ENDPOINTS
// GET    /api/wishlist/{userId}   — get wishlist
// POST   /api/wishlist/toggle     — toggle { user_id, product_id }
// ============================================================

require_once __DIR__ . '/../config/database.php';

$db = (new Database())->getConnection();
$action = $uri[1] ?? '';
$data = json_decode(file_get_contents("php://input"), true);

if ($method === 'GET' && is_numeric($action)) {
    $userId = (int)$action;
    $stmt = $db->prepare("
        SELECT w.wishlist_id, w.product_id, p.product_name, p.price, p.image_path, c.category_name as category
        FROM wishlists w
        JOIN products p ON w.product_id = p.product_id
        JOIN categories c ON p.category_id = c.category_id
        WHERE w.user_id = :user_id
    ");
    $stmt->execute([':user_id' => $userId]);
    echo json_encode($stmt->fetchAll());

} elseif ($method === 'POST' && $action === 'toggle') {
    $userId = $data['user_id'] ?? 0;
    $productId = $data['product_id'] ?? '';

    if (!$userId || !$productId) {
        http_response_code(400);
        echo json_encode(["error" => "user_id and product_id required"]);
        exit;
    }

    // Check if already in wishlist
    $stmt = $db->prepare("SELECT wishlist_id FROM wishlists WHERE user_id = :user_id AND product_id = :product_id");
    $stmt->execute([':user_id' => $userId, ':product_id' => $productId]);
    $existing = $stmt->fetch();

    if ($existing) {
        $stmt = $db->prepare("DELETE FROM wishlists WHERE wishlist_id = :id");
        $stmt->execute([':id' => $existing['wishlist_id']]);
        echo json_encode(["success" => true, "action" => "removed"]);
    } else {
        $stmt = $db->prepare("INSERT INTO wishlists (user_id, product_id) VALUES (:user_id, :product_id)");
        $stmt->execute([':user_id' => $userId, ':product_id' => $productId]);
        echo json_encode(["success" => true, "action" => "added"]);
    }

} else {
    http_response_code(404);
    echo json_encode(["error" => "Wishlist endpoint not found"]);
}
?>
