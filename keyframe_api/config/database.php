<?php
class Database {
    private $host = "localhost";
    private $db_name = "keyframe_db";
    private $username = "root";
    private $password = "";  // Default XAMPP has no password
    private $conn;

    public function getConnection() {
        $this->conn = null;
        try {
            $this->conn = new PDO(
                "mysql:host=" . $this->host . ";dbname=" . $this->db_name . ";charset=utf8mb4",
                $this->username,
                $this->password
            );
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $this->conn->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
        } catch(PDOException $e) {
            http_response_code(500);
            echo json_encode(["error" => "Database connection failed. Have you imported keyframe_db.sql? Details: " . $e->getMessage()]);
            exit();
        }
        return $this->conn;
    }
}
?>
