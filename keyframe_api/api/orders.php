<?php
// ============================================================
// ORDERS ENDPOINTS
// POST   /api/orders           — create order from cart { user_id }
// GET    /api/orders/{userId}   — list orders for user
// ============================================================

require_once __DIR__ . '/../config/database.php';

$db = (new Database())->getConnection();
$param = $uri[1] ?? '';
$data = json_decode(file_get_contents("php://input"), true);

if ($method === 'POST' && empty($param)) {
    // CREATE ORDER
    $userId = $data['user_id'] ?? 0;
    if (!$userId) {
        http_response_code(400);
        echo json_encode(["error" => "user_id required"]);
        exit;
    }

    // Get cart
    $stmt = $db->prepare("SELECT cart_id FROM carts WHERE user_id = :user_id");
    $stmt->execute([':user_id' => $userId]);
    $cart = $stmt->fetch();

    if (!$cart) {
        http_response_code(400);
        echo json_encode(["error" => "No cart found"]);
        exit;
    }

    // Get cart items
    $stmt = $db->prepare("
        SELECT ci.*, p.price 
        FROM cart_items ci 
        JOIN products p ON ci.product_id = p.product_id 
        WHERE ci.cart_id = :cart_id
    ");
    $stmt->execute([':cart_id' => $cart['cart_id']]);
    $items = $stmt->fetchAll();

    if (empty($items)) {
        http_response_code(400);
        echo json_encode(["error" => "Cart is empty"]);
        exit;
    }

    // Calculate totals
    $subtotal = 0;
    foreach ($items as $item) {
        $subtotal += $item['price'] * $item['quantity'];
    }
    $tax = round($subtotal * 0.08, 2);
    $total = $subtotal + $tax;

    // Generate order number
    $orderNumber = '#KF-' . str_pad(mt_rand(1, 99999), 5, '0', STR_PAD_LEFT);

    // Get default address and payment
    $stmt = $db->prepare("SELECT address_id FROM shipping_addresses WHERE user_id = :user_id AND is_default = TRUE LIMIT 1");
    $stmt->execute([':user_id' => $userId]);
    $addr = $stmt->fetch();

    $stmt = $db->prepare("SELECT payment_method_id FROM payment_methods WHERE user_id = :user_id AND is_default = TRUE LIMIT 1");
    $stmt->execute([':user_id' => $userId]);
    $pay = $stmt->fetch();

    // Begin transaction
    $db->beginTransaction();
    try {
        // Insert order
        $stmt = $db->prepare("
            INSERT INTO orders (order_number, user_id, address_id, payment_method_id, subtotal, tax_amount, total_amount)
            VALUES (:order_number, :user_id, :address_id, :payment_method_id, :subtotal, :tax, :total)
        ");
        $stmt->execute([
            ':order_number' => $orderNumber,
            ':user_id' => $userId,
            ':address_id' => $addr ? $addr['address_id'] : null,
            ':payment_method_id' => $pay ? $pay['payment_method_id'] : null,
            ':subtotal' => $subtotal,
            ':tax' => $tax,
            ':total' => $total
        ]);
        $orderId = $db->lastInsertId();

        // Insert order items
        $stmt = $db->prepare("
            INSERT INTO order_items (order_id, product_id, quantity, unit_price, line_total)
            VALUES (:order_id, :product_id, :quantity, :unit_price, :line_total)
        ");
        foreach ($items as $item) {
            $stmt->execute([
                ':order_id' => $orderId,
                ':product_id' => $item['product_id'],
                ':quantity' => $item['quantity'],
                ':unit_price' => $item['price'],
                ':line_total' => $item['price'] * $item['quantity']
            ]);
        }

        // Clear cart
        $stmtClear = $db->prepare("DELETE FROM cart_items WHERE cart_id = :cart_id");
        $stmtClear->execute([':cart_id' => $cart['cart_id']]);

        $db->commit();

        echo json_encode([
            "success" => true,
            "order_id" => (int)$orderId,
            "order_number" => $orderNumber,
            "total_amount" => $total
        ]);
    } catch (Exception $e) {
        $db->rollBack();
        http_response_code(500);
        echo json_encode(["error" => "Order creation failed: " . $e->getMessage()]);
    }

} elseif ($method === 'GET' && is_numeric($param)) {
    // GET orders for user
    $userId = (int)$param;
    $stmt = $db->prepare("SELECT * FROM orders WHERE user_id = :user_id ORDER BY created_at DESC");
    $stmt->execute([':user_id' => $userId]);
    $orders = $stmt->fetchAll();
    echo json_encode($orders);

} else {
    http_response_code(404);
    echo json_encode(["error" => "Orders endpoint not found"]);
}
?>
