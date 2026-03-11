-- ============================================================
-- KEYFRAME DATABASE — MySQL Compatible
-- Premium Keyboard E-Commerce App
-- ============================================================

CREATE DATABASE IF NOT EXISTS keyframe_db;
USE keyframe_db;

-- 1. USERS
CREATE TABLE users (
    user_id         INT AUTO_INCREMENT PRIMARY KEY,
    username        VARCHAR(50)     NOT NULL UNIQUE,
    email           VARCHAR(100)    NOT NULL UNIQUE,
    password_hash   VARCHAR(255)    NOT NULL,
    full_name       VARCHAR(100)    NOT NULL,
    membership_tier VARCHAR(20)     DEFAULT 'STANDARD',
    auth_provider   VARCHAR(20)     DEFAULT 'LOCAL',
    created_at      DATETIME        DEFAULT CURRENT_TIMESTAMP
);

-- 2. CATEGORIES
CREATE TABLE categories (
    category_id     INT AUTO_INCREMENT PRIMARY KEY,
    category_name   VARCHAR(50)     NOT NULL UNIQUE
);

-- 3. PRODUCTS
CREATE TABLE products (
    product_id      VARCHAR(10)     PRIMARY KEY,
    product_name    VARCHAR(100)    NOT NULL,
    category_id     INT             NOT NULL,
    price           DECIMAL(10,2)   NOT NULL,
    image_path      VARCHAR(255)    NOT NULL,
    stock_quantity  INT             DEFAULT 100,
    created_at      DATETIME        DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- 4. SHIPPING ADDRESSES
CREATE TABLE shipping_addresses (
    address_id      INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT             NOT NULL,
    recipient_name  VARCHAR(100)    NOT NULL,
    address_line1   VARCHAR(255)    NOT NULL,
    address_line2   VARCHAR(255)    DEFAULT NULL,
    city            VARCHAR(100)    NOT NULL,
    province        VARCHAR(100)    DEFAULT NULL,
    postal_code     VARCHAR(20)     NOT NULL,
    phone           VARCHAR(20)     DEFAULT NULL,
    is_default      BOOLEAN         DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 5. PAYMENT METHODS
CREATE TABLE payment_methods (
    payment_method_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT             NOT NULL,
    card_type       VARCHAR(20)     NOT NULL,
    card_last_four  VARCHAR(4)      NOT NULL,
    expiry_month    INT             NOT NULL,
    expiry_year     INT             NOT NULL,
    is_default      BOOLEAN         DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 6. CARTS
CREATE TABLE carts (
    cart_id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT             NOT NULL UNIQUE,
    created_at      DATETIME        DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 7. CART ITEMS
CREATE TABLE cart_items (
    cart_item_id    INT AUTO_INCREMENT PRIMARY KEY,
    cart_id         INT             NOT NULL,
    product_id      VARCHAR(10)     NOT NULL,
    quantity        INT             DEFAULT 1,
    FOREIGN KEY (cart_id) REFERENCES carts(cart_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 8. ORDERS
CREATE TABLE orders (
    order_id        INT AUTO_INCREMENT PRIMARY KEY,
    order_number    VARCHAR(20)     NOT NULL UNIQUE,
    user_id         INT             NOT NULL,
    address_id      INT             DEFAULT NULL,
    payment_method_id INT           DEFAULT NULL,
    subtotal        DECIMAL(10,2)   NOT NULL,
    tax_amount      DECIMAL(10,2)   NOT NULL,
    total_amount    DECIMAL(10,2)   NOT NULL,
    order_status    VARCHAR(20)     DEFAULT 'CONFIRMED',
    created_at      DATETIME        DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (address_id) REFERENCES shipping_addresses(address_id),
    FOREIGN KEY (payment_method_id) REFERENCES payment_methods(payment_method_id)
);

-- 9. ORDER ITEMS
CREATE TABLE order_items (
    order_item_id   INT AUTO_INCREMENT PRIMARY KEY,
    order_id        INT             NOT NULL,
    product_id      VARCHAR(10)     NOT NULL,
    quantity        INT             NOT NULL,
    unit_price      DECIMAL(10,2)   NOT NULL,
    line_total      DECIMAL(10,2)   NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 10. WISHLISTS
CREATE TABLE wishlists (
    wishlist_id     INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT             NOT NULL,
    product_id      VARCHAR(10)     NOT NULL,
    created_at      DATETIME        DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    UNIQUE KEY (user_id, product_id)
);

-- 11. NOTIFICATIONS
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT             NOT NULL,
    title           VARCHAR(100)    NOT NULL,
    message         TEXT            NOT NULL,
    notification_type VARCHAR(30)   DEFAULT 'GENERAL',
    icon            VARCHAR(50)     DEFAULT 'notifications',
    color           VARCHAR(20)     DEFAULT '#FFFFFF',
    is_read         BOOLEAN         DEFAULT FALSE,
    created_at      DATETIME        DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 12. FEEDBACK
CREATE TABLE feedback (
    feedback_id     INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT             NOT NULL,
    message         TEXT            NOT NULL,
    status          VARCHAR(20)     DEFAULT 'PENDING',
    created_at      DATETIME        DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 13. ISSUE REPORTS
CREATE TABLE issue_reports (
    report_id       INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT             NOT NULL,
    issue_type      VARCHAR(30)     NOT NULL,
    details         TEXT            NOT NULL,
    screenshot_url  VARCHAR(255)    DEFAULT NULL,
    status          VARCHAR(20)     DEFAULT 'OPEN',
    created_at      DATETIME        DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- ============================================================
-- SEED DATA
-- ============================================================

-- Categories
INSERT INTO categories (category_name) VALUES
('Keyboard'), ('Keycaps'), ('Accessories');

-- Products (matching product_model.dart)
INSERT INTO products (product_id, product_name, category_id, price, image_path) VALUES
('k1', 'Wooting 60HE+',         1, 9850.00,  'assets/wooting_60he.jpg'),
('k2', 'Keychron Q1 Pro',       1, 11200.00, 'assets/keychron_q1.jpg'),
('k3', 'Logitech G Pro X TKL',  1, 10500.00, 'assets/logitech_gprox.jpg'),
('k4', 'Glorious GMMK Pro',     1, 9500.00,  'assets/glorious_gmmk.jpg'),
('k5', 'Razer Huntsman V3 Pro',  1, 14200.00, 'assets/razer_huntsman.jpg'),
('k6', 'Ducky One 3 Daybreak',  1, 7200.00,  'assets/ducky_one3.jpg'),
('c1', 'GMK Laser Custom Set',  2, 7800.00,  'assets/gmk_laser.jpg'),
('c2', 'Drop MT3 Camillo',      2, 5400.00,  'assets/mt3_camillo.jpg'),
('a1', 'Premium Coiled Cable',  3, 1850.00,  'assets/coiled_cable.jpg'),
('a2', 'Glorious Padded Wrist Rest', 3, 1400.00, 'assets/wrist_rest.jpg');

-- Sample User (password: password123, hashed with PHP password_hash)
INSERT INTO users (username, email, password_hash, full_name, membership_tier) VALUES
('kaicenat', 'kai.gamer@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Kai Cenat', 'PRO');

-- Cart for sample user
INSERT INTO carts (user_id) VALUES (1);

-- Shipping Address
INSERT INTO shipping_addresses (user_id, recipient_name, address_line1, city, postal_code, is_default) VALUES
(1, 'Kai Gamer', '123 Cyber Avenue', 'Neo Tokyo', '90210', TRUE);

-- Payment Method
INSERT INTO payment_methods (user_id, card_type, card_last_four, expiry_month, expiry_year, is_default) VALUES
(1, 'Visa', '4242', 12, 2028, TRUE);

-- Notifications
INSERT INTO notifications (user_id, title, message, notification_type, icon, color) VALUES
(1, 'Order Shipped', 'Your keyboard ''Cyber Mech X1'' has been shipped.', 'ORDER', 'local_shipping', '#2196F3'),
(1, 'Flash Sale Alert', '50% off on all Keycaps this weekend only!', 'PROMO', 'local_offer', '#4CAF50'),
(1, 'Support Reply', 'We responded to ticket #9281.', 'SUPPORT', 'chat_bubble_outline', '#FF9800');
