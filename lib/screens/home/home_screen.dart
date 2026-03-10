import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../profile/profile_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = 'All';
  String searchQuery = "";
  final List<String> categories = ['All', 'Keyboard', 'Keycaps', 'Accessories'];

  @override
  Widget build(BuildContext context) {
    final filteredProducts = mockProducts.where((product) {
      final matchesCategory = selectedCategory == 'All' || product.category == selectedCategory;
      final matchesSearch = product.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("WELCOME BACK", style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1.2)),
                      Text("SHOP KEYBOARDS", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD033FF))),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
                    child: const Hero(
                      tag: 'profile_avatar',
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/profile_user.jpg'),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- SEARCH ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search Products',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.tune, size: 20, color: Colors.white),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- CATEGORIES ---
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final isSelected = categories[index] == selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => selectedCategory = categories[index]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(categories[index], style: TextStyle(color: isSelected ? Colors.black : Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // --- PRODUCT GRID ---
            Expanded(
              child: filteredProducts.isEmpty
                  ? const Center(child: Text("No products found", style: TextStyle(color: Colors.grey)))
                  : GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  return _ProductCard(product: filteredProducts[index]);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  double _buttonScale = 1.0;
  double _heartScale = 1.0;
  bool _isFavorited = false;

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
      _heartScale = 1.5; // Pulse up
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _heartScale = 1.0); // Pulse back
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(widget.product.imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
        ),
      ),
      child: Stack(
        children: [
          // --- HEART BUTTON ---
          Positioned(
            top: 10, right: 10,
            child: GestureDetector(
              onTap: _toggleFavorite,
              child: AnimatedScale(
                scale: _heartScale,
                duration: const Duration(milliseconds: 100),
                child: CircleAvatar(
                    backgroundColor: Colors.black45,
                    radius: 16,
                    child: Icon(
                        _isFavorited ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: _isFavorited ? Colors.redAccent : Colors.white
                    )
                ),
              ),
            ),
          ),

          // --- INFO & ADD BUTTON ---
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withOpacity(0.9)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product.category.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFD033FF))),
                  Text(widget.product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // PHP Pesos Currency
                      Text("₱${widget.product.price.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),

                      // --- PLUS BUTTON WITH INSTANT ANIMATION ---
                      // We use Listener + GestureDetector for the most responsive feel
                      Listener(
                        onPointerDown: (_) => setState(() => _buttonScale = 0.6), // Instant shrink
                        onPointerUp: (_) => setState(() => _buttonScale = 1.0),  // Instant grow
                        child: GestureDetector(
                          onTap: () {
                            CartService().addToCart(widget.product);
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${widget.product.name} added to bag!"),
                                duration: const Duration(milliseconds: 800),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: const Color(0xFF8C44FF),
                                margin: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
                              ),
                            );
                          },
                          child: AnimatedScale(
                            scale: _buttonScale,
                            duration: const Duration(milliseconds: 100),
                            child: const CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 14,
                                child: Icon(Icons.add, color: Colors.black, size: 20)
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}