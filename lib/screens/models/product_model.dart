class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String imagePath;
  final int stockQuantity;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imagePath,
    this.stockQuantity = 100,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['product_id'] ?? json['id'] ?? '',
      name: json['product_name'] ?? json['name'] ?? '',
      category: json['category'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      imagePath: json['image_path'] ?? json['imagePath'] ?? '',
      stockQuantity: json['stock_quantity'] is int
          ? json['stock_quantity']
          : int.tryParse(json['stock_quantity']?.toString() ?? '100') ?? 100,
    );
  }

  Map<String, dynamic> toJson() => {
    'product_id': id,
    'product_name': name,
    'category': category,
    'price': price,
    'image_path': imagePath,
  };
}