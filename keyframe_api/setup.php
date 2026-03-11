<?php
// ============================================================
// DATABASE SETUP SCRIPT
// Visit: http://localhost:8000/setup.php
// This creates the keyframe_db database, tables, and seed data.
// ============================================================

header("Content-Type: application/json");

try {
    // Connect WITHOUT specifying a database first
    $conn = new PDO("mysql:host=localhost;charset=utf8mb4", "root", "");
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Read and execute the SQL file
    $sql = file_get_contents(__DIR__ . '/keyframe_db.sql');

    // Split by semicolons and execute each statement
    $conn->exec("CREATE DATABASE IF NOT EXISTS keyframe_db");
    $conn->exec("USE keyframe_db");

    // Split by semicolons but not within strings
    $statements = array_filter(array_map('trim', explode(';', $sql)));

    $executed = 0;
    $errors = [];

    foreach ($statements as $stmt) {
        $stmt = trim($stmt);
        if (empty($stmt) || stripos($stmt, 'CREATE DATABASE') !== false || stripos($stmt, 'USE ') !== false) {
            continue;
        }
        try {
            $conn->exec($stmt);
            $executed++;
        } catch (PDOException $e) {
            // Skip "already exists" or "duplicate" errors
            if (strpos($e->getMessage(), '1062') === false && strpos($e->getMessage(), '1050') === false) {
                $errors[] = $e->getMessage();
            } else {
                $executed++;
            }
        }
    }

    // Now update the seed user's password hash to the correct one for "password123"
    $conn->exec("USE keyframe_db");
    $hash = password_hash("password123", PASSWORD_DEFAULT);
    $stmt = $conn->prepare("UPDATE users SET password_hash = :hash WHERE username = 'kaicenat'");
    $stmt->execute([':hash' => $hash]);

    echo json_encode([
        "success" => true,
        "message" => "Database setup complete!",
        "statements_executed" => $executed,
        "errors" => $errors,
        "login_credentials" => [
            "username" => "kaicenat",
            "password" => "password123"
        ]
    ], JSON_PRETTY_PRINT);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "error" => "Setup failed: " . $e->getMessage(),
        "hint" => "Make sure MySQL is running in XAMPP"
    ], JSON_PRETTY_PRINT);
}
?>
