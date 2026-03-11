<?php
// ============================================================
// USERS ENDPOINT
// GET    /api/users/{id}       — Get user profile
// PUT    /api/users/{id}       — Update personal info
// POST   /api/users/password   — Change password
// ============================================================

require_once __DIR__ . '/../config/database.php';

$db = (new Database())->getConnection();
$action = $uri[1] ?? '';

// --- CHANGE PASSWORD ---
if ($action === 'password' && $method === 'POST') {
    $data = json_decode(file_get_contents("php://input"), true);
    $userId = $data['user_id'] ?? 0;
    $currentPassword = $data['current_password'] ?? '';
    $newPassword = $data['new_password'] ?? '';

    if (!$userId || !$currentPassword || !$newPassword) {
        http_response_code(400);
        echo json_encode(["error" => "All fields are required"]);
        exit;
    }

    $stmt = $db->prepare("SELECT password_hash FROM users WHERE user_id = :id");
    $stmt->execute([':id' => (int)$userId]);
    $user = $stmt->fetch();

    if (!$user || !password_verify($currentPassword, $user['password_hash'])) {
        http_response_code(401);
        echo json_encode(["error" => "Current password is incorrect"]);
        exit;
    }

    $newHash = password_hash($newPassword, PASSWORD_DEFAULT);
    $stmt = $db->prepare("UPDATE users SET password_hash = :hash WHERE user_id = :id");
    $stmt->execute([':hash' => $newHash, ':id' => (int)$userId]);
    echo json_encode(["success" => true, "message" => "Password changed successfully"]);
    exit;
}

$userId = $action;

// --- UPDATE PERSONAL INFO ---
if ($method === 'PUT' && is_numeric($userId)) {
    $data = json_decode(file_get_contents("php://input"), true);
    $fullName = $data['full_name'] ?? '';
    $email = $data['email'] ?? '';
    $username = $data['username'] ?? '';

    if (!$fullName || !$email || !$username) {
        http_response_code(400);
        echo json_encode(["error" => "Full name, email, and username are required"]);
        exit;
    }

    // Check if username/email taken by another user
    $stmt = $db->prepare("SELECT user_id FROM users WHERE (username = :username OR email = :email) AND user_id != :id");
    $stmt->execute([':username' => $username, ':email' => $email, ':id' => (int)$userId]);
    if ($stmt->fetch()) {
        http_response_code(409);
        echo json_encode(["error" => "Username or email already taken"]);
        exit;
    }

    $stmt = $db->prepare("UPDATE users SET full_name = :full_name, email = :email, username = :username WHERE user_id = :id");
    $stmt->execute([':full_name' => $fullName, ':email' => $email, ':username' => $username, ':id' => (int)$userId]);

    // Return updated user
    $stmt = $db->prepare("SELECT user_id, username, email, full_name, membership_tier, auth_provider, created_at FROM users WHERE user_id = :id");
    $stmt->execute([':id' => (int)$userId]);
    $user = $stmt->fetch();
    echo json_encode(["success" => true, "user" => $user]);
    exit;
}

// --- GET USER PROFILE ---
if ($method === 'GET' && is_numeric($userId)) {
    $stmt = $db->prepare("SELECT user_id, username, email, full_name, membership_tier, auth_provider, created_at FROM users WHERE user_id = :id");
    $stmt->execute([':id' => (int)$userId]);
    $user = $stmt->fetch();

    if ($user) {
        $stmt = $db->prepare("SELECT * FROM shipping_addresses WHERE user_id = :id AND is_default = TRUE LIMIT 1");
        $stmt->execute([':id' => (int)$userId]);
        $user['address'] = $stmt->fetch() ?: null;

        $stmt = $db->prepare("SELECT payment_method_id, card_type, card_last_four, expiry_month, expiry_year FROM payment_methods WHERE user_id = :id AND is_default = TRUE LIMIT 1");
        $stmt->execute([':id' => (int)$userId]);
        $user['payment_method'] = $stmt->fetch() ?: null;

        echo json_encode($user);
    } else {
        http_response_code(404);
        echo json_encode(["error" => "User not found"]);
    }
    exit;
}

http_response_code(400);
echo json_encode(["error" => "Invalid request"]);
?>
