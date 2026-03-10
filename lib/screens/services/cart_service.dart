import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

// Helper class to store product + quantity
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  // Map to store items by Product ID to handle quantities easily
  final Map<String, CartItem> _cartItems = {};

  List<CartItem> get items => _cartItems.values.toList();

  void addToCart(Product product) {
    if (_cartItems.containsKey(product.id)) {
      _cartItems[product.id]!.quantity++;
    } else {
      _cartItems[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void removeSingleItem(Product product) {
    if (_cartItems.containsKey(product.id)) {
      if (_cartItems[product.id]!.quantity > 1) {
        _cartItems[product.id]!.quantity--;
      } else {
        _cartItems.remove(product.id);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // Calculate total based on quantity
  double get subtotal => _cartItems.values.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  double get tax => subtotal * 0.08;
  double get total => subtotal + tax;

  // Total number of actual items (for the badge)
  int get itemCount => _cartItems.values.fold(0, (sum, item) => sum + item.quantity);
}