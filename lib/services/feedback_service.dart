import 'api_service.dart';

class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  final ApiService _api = ApiService();

  Future<void> submitFeedback(int userId, String message) async {
    await _api.post('feedback', {
      'user_id': userId,
      'message': message,
    });
  }

  Future<void> submitIssueReport(int userId, String issueType, String details) async {
    await _api.post('issues', {
      'user_id': userId,
      'issue_type': issueType,
      'details': details,
    });
  }
}
