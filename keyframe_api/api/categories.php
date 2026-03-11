<?php
// ============================================================
// CATEGORIES ENDPOINT
// GET /api/categories
// ============================================================

require_once __DIR__ . '/../config/database.php';

$db = (new Database())->getConnection();

if ($method !== 'GET') {
    http_response_code(405);
    echo json_encode(["error" => "Method not allowed"]);
    exit;
}

$stmt = $db->query("SELECT * FROM categories ORDER BY category_name");
$categories = $stmt->fetchAll();
echo json_encode($categories);
?>
