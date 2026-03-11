import 'package:flutter/material.dart';
import 'notifications_screen.dart';
import 'personal_info_screen.dart';
import 'payment_methods_screen.dart';
import 'security_screen.dart';
import 'wishlist_screen.dart';
import '../support/report_issue_screen.dart';
import '../support/feedback_screen.dart';
import '../support/system_error_screen.dart';
import '../auth/login_screen.dart';
import '../../services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          child: Column(
            children: [
              Hero(
                tag: 'profile_avatar',
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF8C44FF),
                  child: Text(
                    _getInitials(user?.fullName ?? 'G'),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(user?.fullName ?? "Guest", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(user?.email ?? "", style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: const Color(0xFF2A0D45),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.purpleAccent)
                  ),
                  child: Text(
                    "${user?.membershipTier ?? 'STANDARD'} MEMBER",
                    style: const TextStyle(color: Colors.purpleAccent, fontSize: 10, fontWeight: FontWeight.bold),
                  )
              ),
              const SizedBox(height: 30),

              _buildProfileItem(context, Icons.person_outline, "Personal Information",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalInfoPage()))),
              _buildProfileItem(context, Icons.credit_card, "Payment Methods",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsPage()))),
              _buildProfileItem(context, Icons.shield_outlined, "Security",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityPage()))),
              _buildProfileItem(context, Icons.notifications_none, "Notifications",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()))),
              _buildProfileItem(context, Icons.favorite_border, "My Wishlist",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistPage()))),
              _buildProfileItem(context, Icons.warning_amber_rounded, "Test Error Page",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ErrorPage()))),
              _buildProfileItem(context, Icons.bug_report_outlined, "Report Issue",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportIssuePage()))),
              _buildProfileItem(context, Icons.feedback_outlined, "Send Feedback",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackPage()))),

              const SizedBox(height: 30),

              TextButton.icon(
                onPressed: () {
                  AuthService().logout();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text("Sign Out", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, IconData icon, String title, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16)
      ),
      child: ListTile(
        onTap: onTap ?? () {},
        leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white70, size: 20)
        ),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  static String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'G';
  }
}