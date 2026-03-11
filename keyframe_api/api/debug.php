<?php
// ============================================================
// DEBUG: Check what users exist in the database
// Visit: http://localhost:8000/api/debug
// ============================================================

require_once __DIR__ . '/../config/database.php';

header("Content-Type: application/json");

try {
    $db = (new Database())->getConnection();
    
    // List all users (without passwords)
    $stmt = $db->query("SELECT user_id, username, email, full_name, membership_tier, LENGTH(password_hash) as hash_length FROM users");
    $users = $stmt->fetchAll();
    
    // Test password verification for each user with "password123"
    $stmt2 = $db->query("SELECT user_id, username, password_hash FROM users");
    $verifyResults = [];
    while ($row = $stmt2->fetch()) {
        $verifyResults[] = [
            "username" => $row['username'],
            "password123_matches" => password_verify("password123", $row['password_hash']),
            "hash_preview" => substr($row['password_hash'], 0, 20) . "..."
        ];
    }

    echo json_encode([
        "users" => $users,
        "password_verification" => $verifyResults,
        "tables" => $db->query("SHOW TABLES")->fetchAll(PDO::FETCH_COLUMN)
    ], JSON_PRETTY_PRINT);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["error" => $e->getMessage()]);
}
?>
