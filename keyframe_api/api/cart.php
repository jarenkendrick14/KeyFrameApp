<?php
// ============================================================
// CART ENDPOINTS
// GET    /api/cart/{userId}   — get cart items
// POST   /api/cart/add        — add item { user_id, product_id }
// POST   /api/cart/remove     — remove/decrement { user_id, product_id }
// POST   /api/cart/clear      — clear cart { user_id }
// ============================================================

require_once __DIR__ . '/../config/database.php';

$db = (new Database())->getConnection();
$action = $uri[1] ?? '';
$data = json_decode(file_get_contents("php://input"), true);

// Helper: get or create cart for user
function getCartId($db, $userId) {
    $stmt = $db->prepare("SELECT cart_id FROM carts WHERE user_id = :user_id");
    $stmt->execute([':user_id' => $userId]);
    $cart = $stmt->fetch();
    if ($cart) return $cart['cart_id'];

    $stmt = $db->prepare("INSERT INTO carts (user_id) VALUES (:user_id)");
    $stmt->execute([':user_id' => $userId]);
    return $db->lastInsertId();
}

if ($method === 'GET' && is_numeric($action)) {
    // GET cart items for user
    $userId = (int)$action;
    $cartId = getCartId($db, $userId);

    $stmt = $db->prepare("
        SELECT ci.cart_item_id, ci.quantity, 
               p.product_id, p.product_name, p.price, p.image_path,
               c.category_name as category
        FROM cart_items ci
        JOIN products p ON ci.product_id = p.product_id
        JOIN categories c ON p.category_id = c.category_id
        WHERE ci.cart_id = :cart_id
    ");
    $stmt->execute([':cart_id' => $cartId]);
    $items = $stmt->fetchAll();

    // Calculate totals
    $subtotal = 0;
    foreach ($items as &$item) {
        $item['line_total'] = $item['price'] * $item['quantity'];
        $subtotal += $item['line_total'];
    }
    $tax = round($subtotal * 0.08, 2);

    echo json_encode([
        "cart_id" => $cartId,
        "items" => $items,
        "subtotal" => $subtotal,
        "tax" => $tax,
        "total" => $subtotal + $tax,
        "item_count" => array_sum(array_column($items, 'quantity'))
    ]);

} elseif ($method === 'POST' && $action === 'add') {
    $userId = $data['user_id'] ?? 0;
    $productId = $data['product_id'] ?? '';

    if (!$userId || !$productId) {
        http_response_code(400);
        echo json_encode(["error" => "user_id and product_id required"]);
        exit;
    }

    $cartId = getCartId($db, $userId);

    // Check if item already in cart
    $stmt = $db->prepare("SELECT cart_item_id, quantity FROM cart_items WHERE cart_id = :cart_id AND product_id = :product_id");
    $stmt->execute([':cart_id' => $cartId, ':product_id' => $productId]);
    $existing = $stmt->fetch();

    if ($existing) {
        $stmt = $db->prepare("UPDATE cart_items SET quantity = quantity + 1 WHERE cart_item_id = :id");
        $stmt->execute([':id' => $existing['cart_item_id']]);
    } else {
        $stmt = $db->prepare("INSERT INTO cart_items (cart_id, product_id, quantity) VALUES (:cart_id, :product_id, 1)");
        $stmt->execute([':cart_id' => $cartId, ':product_id' => $productId]);
    }

    echo json_encode(["success" => true]);

} elseif ($method === 'POST' && $action === 'remove') {
    $userId = $data['user_id'] ?? 0;
    $productId = $data['product_id'] ?? '';

    if (!$userId || !$productId) {
        http_response_code(400);
        echo json_encode(["error" => "user_id and product_id required"]);
        exit;
    }

    $cartId = getCartId($db, $userId);

    $stmt = $db->prepare("SELECT cart_item_id, quantity FROM cart_items WHERE cart_id = :cart_id AND product_id = :product_id");
    $stmt->execute([':cart_id' => $cartId, ':product_id' => $productId]);
    $item = $stmt->fetch();

    if ($item) {
        if ($item['quantity'] > 1) {
            $stmt = $db->prepare("UPDATE cart_items SET quantity = quantity - 1 WHERE cart_item_id = :id");
            $stmt->execute([':id' => $item['cart_item_id']]);
        } else {
            $stmt = $db->prepare("DELETE FROM cart_items WHERE cart_item_id = :id");
            $stmt->execute([':id' => $item['cart_item_id']]);
        }
    }

    echo json_encode(["success" => true]);

} elseif ($method === 'POST' && $action === 'clear') {
    $userId = $data['user_id'] ?? 0;
    if (!$userId) {
        http_response_code(400);
        echo json_encode(["error" => "user_id required"]);
        exit;
    }

    $cartId = getCartId($db, $userId);
    $stmt = $db->prepare("DELETE FROM cart_items WHERE cart_id = :cart_id");
    $stmt->execute([':cart_id' => $cartId]);

    echo json_encode(["success" => true]);

} else {
    http_response_code(404);
    echo json_encode(["error" => "Cart action not found"]);
}
?>
