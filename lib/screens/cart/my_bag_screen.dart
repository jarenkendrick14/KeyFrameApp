import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import 'review_order_screen.dart';

class BagPage extends StatelessWidget {
  const BagPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: CartService(),
        builder: (context, child) {
          final cartItems = CartService().items;

          // EMPTY STATE
          if (cartItems.isEmpty) {
            return Scaffold(
              appBar: AppBar(title: const Text("My Bag (0)")),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
                      child: const Icon(Icons.shopping_bag_outlined, size: 40, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    const Text("Your bag is empty.", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            );
          }

          // FILLED STATE
          return Scaffold(
            appBar: AppBar(title: Text("My Bag (${CartService().itemCount})"), centerTitle: true),
            // Using Column + Expanded ensures the list takes available space
            // and the Checkout section sits at the bottom, above the nav bar.
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartItems[index];
                      final product = cartItem.product;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            // IMAGE (Using Asset now)
                            ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  product.imagePath,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(width: 80, height: 80, color: Colors.grey[800], child: const Icon(Icons.image_not_supported));
                                  },
                                )
                            ),
                            const SizedBox(width: 16),
                            // INFO & QUANTITY
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text(product.category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("\₱${product.price}", style: const TextStyle(color: Color(0xFF8C44FF), fontWeight: FontWeight.bold, fontSize: 16)),

                                        // QUANTITY CONTROLS
                                        Container(
                                          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.remove, size: 16, color: Colors.white),
                                                onPressed: () => CartService().removeSingleItem(product),
                                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                                padding: EdgeInsets.zero,
                                              ),
                                              Text("${cartItem.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                              IconButton(
                                                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                                                onPressed: () => CartService().addToCart(product),
                                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                                padding: EdgeInsets.zero,
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                  ]
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // CHECKOUT SECTION
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), // Bottom padding 100 prevents Nav Bar overlap
                  decoration: const BoxDecoration(
                      color: Color(0xFF0A0A0A),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [BoxShadow(color: Colors.black, blurRadius: 20, offset: Offset(0, -5))]
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Subtotal", style: TextStyle(color: Colors.grey)), Text("\₱${CartService().subtotal.toStringAsFixed(2)}")]),
                      const SizedBox(height: 10),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text("\₱${CartService().total.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ReviewOrderPage()));
                          },
                          child: const Text("Checkout"),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        }
    );
  }
}