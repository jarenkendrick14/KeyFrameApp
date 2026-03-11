import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    if (user != null) {
      _fullNameController.text = user.fullName;
      _usernameController.text = user.username;
      _emailController.text = user.email;
    }
  }

  Future<void> _saveChanges() async {
    final userId = AuthService().currentUser?.userId;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService().put('users/$userId', {
        'full_name': _fullNameController.text.trim(),
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
      });

      // Re-login to refresh the stored user data
      if (response['user'] != null) {
        await AuthService().login(_usernameController.text.trim(), '');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated!"), backgroundColor: Color(0xFF8C44FF)),
        );
        setState(() => _hasChanges = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Information"),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isLoading ? null : _saveChanges,
              child: _isLoading
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text("Save", style: TextStyle(color: Color(0xFF8C44FF), fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF8C44FF),
                child: Text(
                  _getInitials(_fullNameController.text),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30),

            const Text("FULL NAME", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _fullNameController,
              onChanged: (_) => setState(() => _hasChanges = true),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline, color: Colors.grey)),
            ),
            const SizedBox(height: 20),

            const Text("USERNAME", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              onChanged: (_) => setState(() => _hasChanges = true),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.alternate_email, color: Colors.grey)),
            ),
            const SizedBox(height: 20),

            const Text("EMAIL", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              onChanged: (_) => setState(() => _hasChanges = true),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.email_outlined, color: Colors.grey)),
            ),
            const SizedBox(height: 20),

            // Read-only info
            const Text("MEMBERSHIP", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.purpleAccent, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    "${AuthService().currentUser?.membershipTier ?? 'STANDARD'} MEMBER",
                    style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
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
