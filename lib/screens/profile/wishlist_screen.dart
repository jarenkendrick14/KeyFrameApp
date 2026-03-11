import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<dynamic> _wishlistItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final userId = AuthService().currentUser?.userId;
    if (userId == null) return;
    try {
      final response = await ApiService().get('wishlist/$userId');
      if (mounted) setState(() { _wishlistItems = response as List; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFromWishlist(String productId) async {
    final userId = AuthService().currentUser?.userId;
    if (userId == null) return;
    try {
      await ApiService().post('wishlist/toggle', {'user_id': userId, 'product_id': productId});
      await _loadWishlist();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Wishlist")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8C44FF)))
          : _wishlistItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
                        child: const Icon(Icons.favorite_border, size: 40, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      const Text("No favorites yet", style: TextStyle(color: Colors.grey, fontSize: 16)),
                      const SizedBox(height: 8),
                      const Text("Tap the ♥ on products to save them here", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _wishlistItems.length,
                  itemBuilder: (context, index) {
                    final item = _wishlistItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              item['image_path'] ?? '',
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 70, height: 70,
                                color: Colors.grey[800],
                                child: const Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['product_name'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "₱${double.tryParse(item['price']?.toString() ?? '0')?.toStringAsFixed(0) ?? '0'}",
                                  style: const TextStyle(color: Color(0xFF8C44FF), fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              // Add to cart
                              IconButton(
                                onPressed: () {
                                  final product = Product(
                                    id: item['product_id'] ?? '',
                                    name: item['product_name'] ?? '',
                                    category: item['category'] ?? '',
                                    price: double.tryParse(item['price']?.toString() ?? '0') ?? 0,
                                    imagePath: item['image_path'] ?? '',
                                  );
                                  CartService().addToCart(product);
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("${item['product_name']} added to bag!"),
                                      backgroundColor: const Color(0xFF8C44FF),
                                      duration: const Duration(milliseconds: 800),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add_shopping_cart, color: Colors.white70, size: 20),
                              ),
                              // Remove from wishlist
                              IconButton(
                                onPressed: () => _removeFromWishlist(item['product_id'].toString()),
                                icon: const Icon(Icons.favorite, color: Colors.redAccent, size: 20),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
