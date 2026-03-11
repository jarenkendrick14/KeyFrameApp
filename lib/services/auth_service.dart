import '../screens/models/user_model.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _api = ApiService();

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<User> login(String username, String password) async {
    final response = await _api.post('auth/login', {
      'username': username,
      'password': password,
    });
    if (response['user'] == null) {
      throw Exception(response['error'] ?? 'Login failed — unexpected response');
    }
    _currentUser = User.fromJson(response['user']);
    return _currentUser!;
  }

  Future<void> register(String username, String email, String password, String fullName) async {
    await _api.post('auth/register', {
      'username': username,
      'email': email,
      'password': password,
      'full_name': fullName,
    });
  }

  void logout() {
    _currentUser = null;
  }
}
