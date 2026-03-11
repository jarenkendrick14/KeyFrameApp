<?php
// ============================================================
// PRODUCTS ENDPOINTS
// GET /api/products          — list all (optional ?category=Keyboard)
// GET /api/products/{id}     — get single product
// ============================================================

require_once __DIR__ . '/../config/database.php';

$db = (new Database())->getConnection();
$productId = $uri[1] ?? null;

if ($method !== 'GET') {
    http_response_code(405);
    echo json_encode(["error" => "Method not allowed"]);
    exit;
}

if ($productId) {
    // GET single product
    $stmt = $db->prepare("
        SELECT p.*, c.category_name as category 
        FROM products p 
        JOIN categories c ON p.category_id = c.category_id 
        WHERE p.product_id = :id
    ");
    $stmt->execute([':id' => $productId]);
    $product = $stmt->fetch();

    if ($product) {
        echo json_encode($product);
    } else {
        http_response_code(404);
        echo json_encode(["error" => "Product not found"]);
    }
} else {
    // GET all products
    $category = $_GET['category'] ?? null;

    if ($category && $category !== 'All') {
        $stmt = $db->prepare("
            SELECT p.*, c.category_name as category 
            FROM products p 
            JOIN categories c ON p.category_id = c.category_id 
            WHERE c.category_name = :category
            ORDER BY p.product_name
        ");
        $stmt->execute([':category' => $category]);
    } else {
        $stmt = $db->query("
            SELECT p.*, c.category_name as category 
            FROM products p 
            JOIN categories c ON p.category_id = c.category_id 
            ORDER BY p.product_name
        ");
    }

    $products = $stmt->fetchAll();
    echo json_encode($products);
}
?>
