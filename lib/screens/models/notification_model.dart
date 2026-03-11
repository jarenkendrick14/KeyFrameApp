import 'package:flutter/material.dart';

class AppNotification {
  final int notificationId;
  final String title;
  final String message;
  final String notificationType;
  final String icon;
  final String color;
  final bool isRead;
  final String createdAt;

  AppNotification({
    required this.notificationId,
    required this.title,
    required this.message,
    this.notificationType = 'GENERAL',
    this.icon = 'notifications',
    this.color = '#FFFFFF',
    this.isRead = false,
    this.createdAt = '',
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      notificationId: json['notification_id'] is int ? json['notification_id'] : int.parse(json['notification_id'].toString()),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      notificationType: json['notification_type'] ?? 'GENERAL',
      icon: json['icon'] ?? 'notifications',
      color: json['color'] ?? '#FFFFFF',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['created_at'] ?? '',
    );
  }

  IconData get iconData {
    switch (icon) {
      case 'local_shipping': return Icons.local_shipping;
      case 'local_offer': return Icons.local_offer;
      case 'chat_bubble_outline': return Icons.chat_bubble_outline;
      case 'shopping_bag': return Icons.shopping_bag;
      default: return Icons.notifications;
    }
  }

  Color get colorValue {
    try {
      return Color(int.parse(color.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.white;
    }
  }

  String get timeAgo {
    try {
      final dt = DateTime.parse(createdAt);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}M AGO';
      if (diff.inHours < 24) return '${diff.inHours}H AGO';
      if (diff.inDays < 7) return '${diff.inDays}D AGO';
      return '${(diff.inDays / 7).floor()}W AGO';
    } catch (_) {
      return '';
    }
  }
}
