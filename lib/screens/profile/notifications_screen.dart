import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../../services/auth_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final userId = AuthService().currentUser?.userId;
    if (userId == null) return;

    try {
      final notifications = await NotificationService().getNotifications(userId);
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications"), actions: [TextButton(onPressed: (){}, child: const Text("Mark all as read"))]),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8C44FF)))
          : _notifications.isEmpty
              ? const Center(child: Text("No notifications", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notif = _notifications[index];
                    return NotificationTile(
                      icon: notif.iconData,
                      color: notif.colorValue,
                      title: notif.title,
                      desc: notif.message,
                      time: notif.timeAgo,
                      isUnread: !notif.isRead,
                    );
                  },
                ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  final String time;
  final bool isUnread;

  const NotificationTile({super.key, required this.icon, required this.color, required this.title, required this.desc, required this.time, required this.isUnread});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16), border: isUnread ? Border.all(color: Colors.purple.withOpacity(0.3)) : null),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), if(isUnread) const CircleAvatar(radius: 4, backgroundColor: Colors.red)]),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            Text(time, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
          ]))
        ],
      ),
    );
  }
}