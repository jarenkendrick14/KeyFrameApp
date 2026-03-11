<?php
// ============================================================
// AUTH ENDPOINTS
// POST /api/auth/login
// POST /api/auth/register
// ============================================================

require_once __DIR__ . '/../config/database.php';

$db = (new Database())->getConnection();
$action = $uri[1] ?? '';
$data = json_decode(file_get_contents("php://input"), true);

switch ($action) {
    case 'login':
        if ($method !== 'POST') { http_response_code(405); echo json_encode(["error" => "Method not allowed"]); exit; }

        $username = $data['username'] ?? '';
        $password = $data['password'] ?? '';

        if (empty($username) || empty($password)) {
            http_response_code(400);
            echo json_encode(["error" => "Username and password are required"]);
            exit;
        }

        $stmt = $db->prepare("SELECT * FROM users WHERE username = :username");
        $stmt->execute([':username' => $username]);
        $user = $stmt->fetch();

        if ($user && password_verify($password, $user['password_hash'])) {
            unset($user['password_hash']);
            echo json_encode(["success" => true, "user" => $user]);
        } else {
            http_response_code(401);
            echo json_encode(["error" => "Invalid username or password"]);
        }
        break;

    case 'register':
        if ($method !== 'POST') { http_response_code(405); echo json_encode(["error" => "Method not allowed"]); exit; }

        $username = $data['username'] ?? '';
        $email = $data['email'] ?? '';
        $password = $data['password'] ?? '';
        $fullName = $data['full_name'] ?? '';

        if (empty($username) || empty($email) || empty($password) || empty($fullName)) {
            http_response_code(400);
            echo json_encode(["error" => "All fields are required"]);
            exit;
        }

        // Check if username or email already exists
        $stmt = $db->prepare("SELECT user_id FROM users WHERE username = :username OR email = :email");
        $stmt->execute([':username' => $username, ':email' => $email]);
        if ($stmt->fetch()) {
            http_response_code(409);
            echo json_encode(["error" => "Username or email already exists"]);
            exit;
        }

        $hash = password_hash($password, PASSWORD_DEFAULT);
        $stmt = $db->prepare("INSERT INTO users (username, email, password_hash, full_name) VALUES (:username, :email, :hash, :full_name)");
        $stmt->execute([':username' => $username, ':email' => $email, ':hash' => $hash, ':full_name' => $fullName]);

        $userId = $db->lastInsertId();

        // Create a cart for the new user
        $stmt = $db->prepare("INSERT INTO carts (user_id) VALUES (:user_id)");
        $stmt->execute([':user_id' => $userId]);

        echo json_encode(["success" => true, "user_id" => (int)$userId]);
        break;

    default:
        http_response_code(404);
        echo json_encode(["error" => "Auth action not found"]);
        break;
}
?>
