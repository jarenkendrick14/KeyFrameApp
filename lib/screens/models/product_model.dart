class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String imagePath;

  Product({required this.id, required this.name, required this.category, required this.price, required this.imagePath});
}

final List<Product> mockProducts = [
  Product(id: 'k1', name: 'Wooting 60HE+', category: 'Keyboard', price: 9850.00, imagePath: 'assets/wooting_60he.jpg'),
  Product(id: 'k2', name: 'Keychron Q1 Pro', category: 'Keyboard', price: 11200.00, imagePath: 'assets/keychron_q1.jpg'),
  Product(id: 'k3', name: 'Logitech G Pro X TKL', category: 'Keyboard', price: 10500.00, imagePath: 'assets/logitech_gprox.jpg'),
  Product(id: 'k4', name: 'Glorious GMMK Pro', category: 'Keyboard', price: 9500.00, imagePath: 'assets/glorious_gmmk.jpg'),
  Product(id: 'k5', name: 'Razer Huntsman V3 Pro', category: 'Keyboard', price: 14200.00, imagePath: 'assets/razer_huntsman.jpg'),
  Product(id: 'k6', name: 'Ducky One 3 Daybreak', category: 'Keyboard', price: 7200.00, imagePath: 'assets/ducky_one3.jpg'),
  Product(id: 'c1', name: 'GMK Laser Custom Set', category: 'Keycaps', price: 7800.00, imagePath: 'assets/gmk_laser.jpg'),
  Product(id: 'c2', name: 'Drop MT3 Camillo', category: 'Keycaps', price: 5400.00, imagePath: 'assets/mt3_camillo.jpg'),
  Product(id: 'a1', name: 'Premium Coiled Cable', category: 'Accessories', price: 1850.00, imagePath: 'assets/coiled_cable.jpg'),
  Product(id: 'a2', name: 'Glorious Padded Wrist Rest', category: 'Accessories', price: 1400.00, imagePath: 'assets/wrist_rest.jpg'),
];