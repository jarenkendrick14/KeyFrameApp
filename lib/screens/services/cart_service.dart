import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

// Helper class to store product + quantity
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product(
        id: json['product_id'] ?? '',
        name: json['product_name'] ?? '',
        category: json['category'] ?? '',
        price: double.tryParse(json['price'].toString()) ?? 0,
        imagePath: json['image_path'] ?? '',
      ),
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity'].toString()) ?? 1,
    );
  }
}

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final ApiService _api = ApiService();

  List<CartItem> _cartItems = [];
  double _subtotal = 0;
  double _tax = 0;
  double _total = 0;
  int _itemCount = 0;

  List<CartItem> get items => _cartItems;
  double get subtotal => _subtotal;
  double get tax => _tax;
  double get total => _total;
  int get itemCount => _itemCount;

  int? get _userId => AuthService().currentUser?.userId;

  Future<void> loadCart() async {
    if (_userId == null) return;
    try {
      final response = await _api.get('cart/$_userId');
      final itemsJson = response['items'] as List;
      _cartItems = itemsJson.map((json) => CartItem.fromJson(json)).toList();
      _subtotal = double.tryParse(response['subtotal'].toString()) ?? 0;
      _tax = double.tryParse(response['tax'].toString()) ?? 0;
      _total = double.tryParse(response['total'].toString()) ?? 0;
      _itemCount = response['item_count'] is int ? response['item_count'] : int.tryParse(response['item_count'].toString()) ?? 0;
      notifyListeners();
    } catch (e) {
      debugPrint('CartService.loadCart error: $e');
    }
  }

  Future<void> addToCart(Product product) async {
    if (_userId == null) return;
    try {
      await _api.post('cart/add', {
        'user_id': _userId,
        'product_id': product.id,
      });
      await loadCart();
    } catch (e) {
      debugPrint('CartService.addToCart error: $e');
    }
  }

  Future<void> removeSingleItem(Product product) async {
    if (_userId == null) return;
    try {
      await _api.post('cart/remove', {
        'user_id': _userId,
        'product_id': product.id,
      });
      await loadCart();
    } catch (e) {
      debugPrint('CartService.removeSingleItem error: $e');
    }
  }

  Future<void> clearCart() async {
    if (_userId == null) return;
    try {
      await _api.post('cart/clear', {'user_id': _userId});
      _cartItems = [];
      _subtotal = 0;
      _tax = 0;
      _total = 0;
      _itemCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('CartService.clearCart error: $e');
    }
  }
}