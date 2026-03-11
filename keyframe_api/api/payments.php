<?php
// ============================================================
// PAYMENT METHODS ENDPOINT
// GET    /api/payments/{userId}       — List user's payment methods
// POST   /api/payments/add            — Add payment method
// POST   /api/payments/delete         — Delete payment method
// POST   /api/payments/default        — Set default payment method
// ============================================================

require_once __DIR__ . '/../config/database.php';

$db = (new Database())->getConnection();
$data = json_decode(file_get_contents("php://input"), true);
$action = $uri[1] ?? '';

// --- ADD PAYMENT METHOD ---
if ($action === 'add' && $method === 'POST') {
    $userId = $data['user_id'] ?? 0;
    $cardType = $data['card_type'] ?? '';
    $cardLastFour = $data['card_last_four'] ?? '';
    $expiryMonth = $data['expiry_month'] ?? '';
    $expiryYear = $data['expiry_year'] ?? '';

    if (!$userId || !$cardType || !$cardLastFour || !$expiryMonth || !$expiryYear) {
        http_response_code(400);
        echo json_encode(["error" => "All fields are required"]);
        exit;
    }

    // Check if user has other payment methods; if not, make this default
    $stmt = $db->prepare("SELECT COUNT(*) as cnt FROM payment_methods WHERE user_id = :uid");
    $stmt->execute([':uid' => (int)$userId]);
    $count = $stmt->fetch()['cnt'];
    $isDefault = $count == 0 ? 1 : 0;

    $stmt = $db->prepare("INSERT INTO payment_methods (user_id, card_type, card_last_four, expiry_month, expiry_year, is_default) VALUES (:uid, :type, :last4, :em, :ey, :def)");
    $stmt->execute([':uid' => (int)$userId, ':type' => $cardType, ':last4' => $cardLastFour, ':em' => $expiryMonth, ':ey' => $expiryYear, ':def' => $isDefault]);
    echo json_encode(["success" => true, "payment_method_id" => (int)$db->lastInsertId()]);
    exit;
}

// --- DELETE PAYMENT METHOD ---
if ($action === 'delete' && $method === 'POST') {
    $paymentId = $data['payment_method_id'] ?? 0;
    $userId = $data['user_id'] ?? 0;

    $stmt = $db->prepare("DELETE FROM payment_methods WHERE payment_method_id = :pid AND user_id = :uid");
    $stmt->execute([':pid' => (int)$paymentId, ':uid' => (int)$userId]);
    echo json_encode(["success" => true]);
    exit;
}

// --- SET DEFAULT ---
if ($action === 'default' && $method === 'POST') {
    $paymentId = $data['payment_method_id'] ?? 0;
    $userId = $data['user_id'] ?? 0;

    // Unset all defaults
    $stmt = $db->prepare("UPDATE payment_methods SET is_default = FALSE WHERE user_id = :uid");
    $stmt->execute([':uid' => (int)$userId]);

    // Set the chosen one
    $stmt = $db->prepare("UPDATE payment_methods SET is_default = TRUE WHERE payment_method_id = :pid AND user_id = :uid");
    $stmt->execute([':pid' => (int)$paymentId, ':uid' => (int)$userId]);
    echo json_encode(["success" => true]);
    exit;
}

// --- LIST PAYMENT METHODS ---
if (is_numeric($action) && $method === 'GET') {
    $stmt = $db->prepare("SELECT * FROM payment_methods WHERE user_id = :uid ORDER BY is_default DESC");
    $stmt->execute([':uid' => (int)$action]);
    echo json_encode($stmt->fetchAll());
    exit;
}

http_response_code(400);
echo json_encode(["error" => "Invalid request"]);
?>
