import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../cart/my_bag_screen.dart';
import '../profile/profile_screen.dart';
import '../services/cart_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _bagBounceController;
  int _lastItemCount = 0;

  final List<Widget> _pages = [const HomePage(), const BagPage(), const ProfilePage()];

  @override
  void initState() {
    super.initState();
    _bagBounceController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        lowerBound: 1.0,
        upperBound: 1.2
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
            color: Color(0xFF0A0A0A),
            border: Border(top: BorderSide(color: Colors.white10))
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_filled),
              _buildAnimatedBagNavItem(1),
              _buildNavItem(2, Icons.person_outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = _currentIndex == index;
    return Material(
      color: Colors.transparent, // Required for InkWell to show ripple
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        customBorder: const CircleBorder(), // Makes ripple circular
        splashColor: Colors.white10,
        child: Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
              shape: BoxShape.circle
          ),
          child: Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 26),
        ),
      ),
    );
  }

  Widget _buildAnimatedBagNavItem(int index) {
    final isSelected = _currentIndex == index;
    return ListenableBuilder(
      listenable: CartService(),
      builder: (context, child) {
        if (CartService().itemCount > _lastItemCount) {
          _bagBounceController.forward().then((_) => _bagBounceController.reverse());
        }
        _lastItemCount = CartService().itemCount;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _currentIndex = index),
            customBorder: const CircleBorder(),
            splashColor: Colors.white10,
            child: ScaleTransition(
              scale: _bagBounceController,
              child: Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
                    shape: BoxShape.circle
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined, color: isSelected ? Colors.white : Colors.grey, size: 26),
                    if (CartService().items.isNotEmpty)
                      Positioned(
                        right: 14, top: 14,
                        child: Container(
                            width: 10, height: 10,
                            decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 1.5)
                            )
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}