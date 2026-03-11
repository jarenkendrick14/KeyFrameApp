import 'api_service.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> createOrder(int userId) async {
    final response = await _api.post('orders', {'user_id': userId});
    return response;
  }

  Future<List<dynamic>> getOrders(int userId) async {
    final response = await _api.get('orders/$userId');
    return response as List;
  }
}
