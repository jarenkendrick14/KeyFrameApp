import '../screens/models/product_model.dart';
import 'api_service.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final ApiService _api = ApiService();

  Future<List<Product>> getProducts({String? category}) async {
    String endpoint = 'products';
    if (category != null && category != 'All') {
      endpoint += '?category=$category';
    }
    final response = await _api.get(endpoint);
    return (response as List).map((json) => Product.fromJson(json)).toList();
  }

  Future<Product> getProductById(String productId) async {
    final response = await _api.get('products/$productId');
    return Product.fromJson(response);
  }

  Future<List<String>> getCategories() async {
    final response = await _api.get('categories');
    return ['All', ...(response as List).map((c) => c['category_name'].toString())];
  }
}
