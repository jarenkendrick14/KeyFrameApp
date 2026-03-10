import 'package:flutter/material.dart';

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 20, spreadRadius: 5)]),
              child: const Icon(Icons.check, size: 40, color: Colors.black),
            ),
            const SizedBox(height: 30),
            const Text("Order Confirmed!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Your gear is on the way. You will\nreceive a tracking number shortly.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [Text("Order ID", style: TextStyle(color: Colors.grey)), SizedBox(width: 100), Text("#KG-8821", style: TextStyle(fontWeight: FontWeight.bold))]),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.home), SizedBox(width: 8), Text("Back to Store")]),
              ),
            )
          ],
        ),
      ),
    );
  }
}