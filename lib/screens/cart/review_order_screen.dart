import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import 'order_confirmed_screen.dart';

class ReviewOrderPage extends StatelessWidget {
  const ReviewOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartService();

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
              child: const Row(
                children: [
                  CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.location_on, color: Colors.purpleAccent)),
                  SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Kai Gamer", style: TextStyle(fontWeight: FontWeight.bold)), Text("123 Cyber Avenue, Neo Tokyo, 90210", style: TextStyle(color: Colors.grey, fontSize: 12))])),
                  Icon(Icons.chevron_right, color: Colors.grey)
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("PAYMENT", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
              child: const Row(
                children: [
                  CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.credit_card, color: Colors.purpleAccent)),
                  SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Visa ending in 4242", style: TextStyle(fontWeight: FontWeight.bold)), Text("Expires 12/28", style: TextStyle(color: Colors.grey, fontSize: 12))])),
                  Icon(Icons.chevron_right, color: Colors.grey)
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Fixed loop for CartItems
            Text("ITEMS (${cart.itemCount})", style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            ...cart.items.map((cartItem) {
              final product = cartItem.product; // Extract the product from the CartItem
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          product.imagePath, // Fixed: product.imagePath
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
                              Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)), // Fixed: product.name
                              Text("${cartItem.quantity}x ${product.category}", style: const TextStyle(color: Colors.grey, fontSize: 10)) // Fixed: product.category
                            ]
                        )
                    ),
                    Text("\₱${(product.price * cartItem.quantity).toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)) // Fixed: product.price
                  ],
                ),
              );
            }),

            const Divider(color: Colors.white10, height: 40),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Subtotal", style: TextStyle(color: Colors.grey)), Text("\₱${cart.subtotal.toStringAsFixed(2)}")]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Tax (8%)", style: TextStyle(color: Colors.grey)), Text("\₱${cart.tax.toStringAsFixed(2)}")]),
            const SizedBox(height: 8),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Shipping", style: TextStyle(color: Colors.grey)), Text("Free", style: TextStyle(color: Colors.green))]),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)), Text("\₱${cart.total.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))]),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  CartService().clearCart();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OrderSuccessPage()));
                },
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle_outline), SizedBox(width: 8), Text("Confirm Order")]),
              ),
            )
          ],
        ),
      ),
    );
  }
}