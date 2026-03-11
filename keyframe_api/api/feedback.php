<?php
// ============================================================
// FEEDBACK ENDPOINT
// POST /api/feedback  { user_id, message }
// ============================================================

require_once __DIR__ . '/../config/database.php';

$db = (new Database())->getConnection();
$data = json_decode(file_get_contents("php://input"), true);

if ($method !== 'POST') {
    http_response_code(405);
    echo json_encode(["error" => "Method not allowed"]);
    exit;
}

$userId = $data['user_id'] ?? 0;
$message = $data['message'] ?? '';

if (!$userId || empty($message)) {
    http_response_code(400);
    echo json_encode(["error" => "user_id and message are required"]);
    exit;
}

$stmt = $db->prepare("INSERT INTO feedback (user_id, message) VALUES (:user_id, :message)");
$stmt->execute([':user_id' => $userId, ':message' => $message]);

echo json_encode(["success" => true, "feedback_id" => (int)$db->lastInsertId()]);
?>
