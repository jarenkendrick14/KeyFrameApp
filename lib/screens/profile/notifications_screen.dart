import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications"), actions: [TextButton(onPressed: (){}, child: const Text("Mark all as read"))]),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text("TODAY", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(height: 10),
          NotificationTile(icon: Icons.local_shipping, color: Colors.blue, title: "Order Shipped", desc: "Your keyboard 'Cyber Mech X1' has been shipped.", time: "2H AGO", isUnread: true),
          NotificationTile(icon: Icons.local_offer, color: Colors.green, title: "Flash Sale Alert", desc: "50% off on all Keycaps this weekend only!", time: "5H AGO", isUnread: true),
          SizedBox(height: 20),
          Text("YESTERDAY", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(height: 10),
          NotificationTile(icon: Icons.chat_bubble_outline, color: Colors.orange, title: "Support Reply", desc: "We responded to ticket #9281.", time: "1D AGO", isUnread: false),
        ],
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