import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../profile/profile_screen.dart';
import '../../services/product_service.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../support/system_error_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = 'All';
  String searchQuery = "";
  List<String> categories = ['All'];
  List<Product> products = [];
  Set<String> wishlistIds = {};
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final fetched = await ProductService().getProducts();
      final cats = await ProductService().getCategories();
      // Load wishlist
      final userId = AuthService().currentUser?.userId;
      if (userId != null) {
        try {
          final wishlistResponse = await ApiService().get('wishlist/$userId');
          final wl = (wishlistResponse as List).map((w) => w['product_id'].toString()).toSet();
          wishlistIds = wl;
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          products = fetched;
          categories = cats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = products.where((product) {
      final matchesCategory = selectedCategory == 'All' || product.category == selectedCategory;
      final matchesSearch = product.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      body: _hasError
          ? ErrorPage(
              errorMessage: _errorMessage,
              onRetry: () {
                setState(() { _hasError = false; _isLoading = true; });
                _loadData();
              },
            )
          : SafeArea(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("WELCOME BACK", style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1.2)),
                      Text(
                        AuthService().currentUser != null
                            ? "HI, ${AuthService().currentUser!.fullName.toUpperCase()}"
                            : "SHOP KEYBOARDS",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD033FF)),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
                    child: Hero(
                      tag: 'profile_avatar',
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF8C44FF),
                        child: Text(
                          _getInitials(AuthService().currentUser?.fullName ?? 'G'),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF8C44FF)))
                  : filteredProducts.isEmpty
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
                            return _ProductCard(
                              product: filteredProducts[index],
                              isFavorited: wishlistIds.contains(filteredProducts[index].id),
                              onFavoriteToggle: (isFav) {
                                setState(() {
                                  if (isFav) {
                                    wishlistIds.add(filteredProducts[index].id);
                                  } else {
                                    wishlistIds.remove(filteredProducts[index].id);
                                  }
                                });
                              },
                            );
                          },
                        ),
            )
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'G';
  }
}

class _ProductCard extends StatefulWidget {
  final Product product;
  final bool isFavorited;
  final Function(bool) onFavoriteToggle;
  const _ProductCard({required this.product, required this.isFavorited, required this.onFavoriteToggle});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  double _buttonScale = 1.0;
  double _heartScale = 1.0;

  void _toggleFavorite() async {
    final userId = AuthService().currentUser?.userId;
    if (userId == null) return;

    try {
      await ApiService().post('wishlist/toggle', {
        'user_id': userId,
        'product_id': widget.product.id,
      });
      widget.onFavoriteToggle(!widget.isFavorited);
    } catch (_) {}

    setState(() => _heartScale = 1.5);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _heartScale = 1.0);
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
                        widget.isFavorited ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: widget.isFavorited ? Colors.redAccent : Colors.white
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
                      Text("₱${widget.product.price.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      Listener(
                        onPointerDown: (_) => setState(() => _buttonScale = 0.6),
                        onPointerUp: (_) => setState(() => _buttonScale = 1.0),
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