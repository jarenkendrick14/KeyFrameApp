import '../screens/models/notification_model.dart';
import 'api_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ApiService _api = ApiService();

  Future<List<AppNotification>> getNotifications(int userId) async {
    final response = await _api.get('notifications/$userId');
    return (response as List).map((json) => AppNotification.fromJson(json)).toList();
  }
}
