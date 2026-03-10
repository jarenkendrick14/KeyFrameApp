import 'package:flutter/material.dart';
// 1. MAKE SURE THIS IMPORT IS HERE AND CORRECT:
import '../dashboard/dashboard_screen.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.5,
              colors: [Color(0xFF2A0D45), Color(0xFF050505)],
            )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.gamepad, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            const Text('Welcome\nBack.', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, height: 1.1)),
            const SizedBox(height: 10),
            const Text('Sign in to enter the GAME', style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 40),
            const TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.email_outlined, color: Colors.grey), hintText: 'USERNAME')),
            const SizedBox(height: 16),
            const TextField(obscureText: true, decoration: InputDecoration(prefixIcon: Icon(Icons.lock_outline, color: Colors.grey), hintText: 'PASSWORD')),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // 2. This is where the error likely occurred.
                // It needs to know exactly what 'DashboardPage' is.
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(width: 8), Icon(Icons.arrow_forward)]),
            ),
            const SizedBox(height: 20),
            const Center(child: Text("OR CONTINUE LOGIN USING", style: TextStyle(fontSize: 10, color: Colors.grey))),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Colors.white24)), child: const Icon(Icons.apple, color: Colors.white))),
                const SizedBox(width: 16),
                Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Colors.white24)), child: const Text("G", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)))),
              ],
            )
          ],
        ),
      ),
    );
  }
}