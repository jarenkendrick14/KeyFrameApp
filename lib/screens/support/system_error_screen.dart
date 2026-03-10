import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.warning_amber_rounded, size: 50, color: Colors.red)),
            const SizedBox(height: 20),
            const Text("System Error", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Something went wrong while loading\nthe requested data. Please try again later.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),

            // -- CHANGE START: Made button bigger --
            SizedBox(
              width: 200, // Fixed width
              height: 55, // Taller
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
                child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home_outlined),
                      SizedBox(width: 8),
                      Text("Return Home")
                    ]
                ),
              ),
            )
            // -- CHANGE END --

          ],
        ),
      ),
    );
  }
}