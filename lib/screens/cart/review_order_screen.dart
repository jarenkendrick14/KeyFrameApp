import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import 'order_confirmed_screen.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../services/api_service.dart';

class ReviewOrderPage extends StatefulWidget {
  const ReviewOrderPage({super.key});

  @override
  State<ReviewOrderPage> createState() => _ReviewOrderPageState();
}

class _ReviewOrderPageState extends State<ReviewOrderPage> {
  bool _isPlacingOrder = false;
  Map<String, dynamic>? _address;
  Map<String, dynamic>? _paymentMethod;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = AuthService().currentUser?.userId;
    if (userId == null) return;

    try {
      final response = await ApiService().get('users/$userId');
      if (mounted) {
        setState(() {
          _address = response['address'];
          _paymentMethod = response['payment_method'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmOrder() async {
    final userId = AuthService().currentUser?.userId;
    if (userId == null) return;

    setState(() => _isPlacingOrder = true);
    try {
      final result = await OrderService().createOrder(userId);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderSuccessPage(orderNumber: result['order_number'] ?? '#KF-00000'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order failed: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isPlacingOrder = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartService();

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Review Order"), centerTitle: true),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF8C44FF))),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Review Order"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("SHIPPING TO", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.location_on, color: Colors.purpleAccent)),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_address?['recipient_name'] ?? 'No address', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      _address != null
                          ? "${_address!['address_line1']}, ${_address!['city']}, ${_address!['postal_code']}"
                          : 'Add a shipping address',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ])),
                  const Icon(Icons.chevron_right, color: Colors.grey)
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("PAYMENT", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.credit_card, color: Colors.purpleAccent)),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      _paymentMethod != null
                          ? "${_paymentMethod!['card_type']} ending in ${_paymentMethod!['card_last_four']}"
                          : 'No payment method',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _paymentMethod != null
                          ? "Expires ${_paymentMethod!['expiry_month']}/${_paymentMethod!['expiry_year']}"
                          : 'Add a payment method',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ])),
                  const Icon(Icons.chevron_right, color: Colors.grey)
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text("ITEMS (${cart.itemCount})", style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            ...cart.items.map((cartItem) {
              final product = cartItem.product;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          product.imagePath,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(width: 50, height: 50, color: Colors.grey),
                        )
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text("${cartItem.quantity}x ${product.category}", style: const TextStyle(color: Colors.grey, fontSize: 10))
                            ]
                        )
                    ),
                    Text("₱${(product.price * cartItem.quantity).toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold))
                  ],
                ),
              );
            }),

            const Divider(color: Colors.white10, height: 40),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Subtotal", style: TextStyle(color: Colors.grey)), Text("₱${cart.subtotal.toStringAsFixed(2)}")]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Tax (8%)", style: TextStyle(color: Colors.grey)), Text("₱${cart.tax.toStringAsFixed(2)}")]),
            const SizedBox(height: 8),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Shipping", style: TextStyle(color: Colors.grey)), Text("Free", style: TextStyle(color: Colors.green))]),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)), Text("₱${cart.total.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))]),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPlacingOrder ? null : _confirmOrder,
                child: _isPlacingOrder
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle_outline), SizedBox(width: 8), Text("Confirm Order")]),
              ),
            )
          ],
        ),
      ),
    );
  }
}