<?php
// ============================================================
// ISSUE REPORTS ENDPOINT
// POST /api/issues  { user_id, issue_type, details }
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
$issueType = $data['issue_type'] ?? '';
$details = $data['details'] ?? '';

if (!$userId || empty($issueType) || empty($details)) {
    http_response_code(400);
    echo json_encode(["error" => "user_id, issue_type, and details are required"]);
    exit;
}

$stmt = $db->prepare("INSERT INTO issue_reports (user_id, issue_type, details) VALUES (:user_id, :issue_type, :details)");
$stmt->execute([':user_id' => $userId, ':issue_type' => $issueType, ':details' => $details]);

echo json_encode(["success" => true, "report_id" => (int)$db->lastInsertId()]);
?>
