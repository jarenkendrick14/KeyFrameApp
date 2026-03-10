import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeIn)));

    _controller.forward();

    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(context, PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => const LoginPage(),
        transitionsBuilder: (context, anim1, anim2, child) => FadeTransition(opacity: anim1, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A0D45), Color(0xFF050505)]),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 40, spreadRadius: 10)],
                  ),
                  child: const Icon(Icons.gamepad, size: 60, color: Color(0xFFFF3B30)),
                ),
              ),
              const SizedBox(height: 30),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const Text('KEYFRAME', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFFFF3B30), letterSpacing: 2.0)),
                    const SizedBox(height: 10),
                    Text('PREMIUM GEAR', style: TextStyle(fontSize: 14, letterSpacing: 6, color: Colors.white.withOpacity(0.6))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}