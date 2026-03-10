import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Feedback")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("How can we improve?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            const TextField(maxLines: 6, decoration: InputDecoration(hintText: "Tell us about your experience...")),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Feedback sent!"))); Navigator.pop(context);}, child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Send Feedback"), SizedBox(width: 8), Icon(Icons.send, size: 16)])))
          ],
        ),
      ),
    );
  }
}