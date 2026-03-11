<?php
// ============================================================
// NOTIFICATIONS ENDPOINT
// GET /api/notifications/{userId}
// ============================================================

require_once __DIR__ . '/../config/database.php';

$db = (new Database())->getConnection();
$userId = $uri[1] ?? '';

if ($method !== 'GET' || !is_numeric($userId)) {
    http_response_code(400);
    echo json_encode(["error" => "GET /api/notifications/{userId} expected"]);
    exit;
}

$stmt = $db->prepare("SELECT * FROM notifications WHERE user_id = :user_id ORDER BY created_at DESC");
$stmt->execute([':user_id' => (int)$userId]);
$notifications = $stmt->fetchAll();

echo json_encode($notifications);
?>
