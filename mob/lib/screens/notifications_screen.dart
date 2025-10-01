import "package:flutter/material.dart";
import "../models/notification.dart" as app_notification;
import "../theme.dart";

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock notifications for demonstration
    final List<app_notification.Notification> notifications = [
      app_notification.Notification(
        id: 1,
        loanId: 101,
        type: "DUE_SOON",
        scheduledAt: DateTime.now().add(const Duration(days: 3)),
        sentAt: null,
        payload: {"amount": 100.0, "currency": "MAD"},
      ),
      app_notification.Notification(
        id: 2,
        loanId: 102,
        type: "D_DAY",
        scheduledAt: DateTime.now(),
        sentAt: DateTime.now(),
        payload: {"amount": 50.0, "currency": "USD"},
      ),
      app_notification.Notification(
        id: 3,
        loanId: 103,
        type: "PAST_DUE",
        scheduledAt: DateTime.now().subtract(const Duration(days: 2)),
        sentAt: DateTime.now().subtract(const Duration(days: 1)),
        payload: {"amount": 200.0, "currency": "EUR"},
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.trustBlue,
        foregroundColor: Colors.white,
        title: const Text("Notifications"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("All notifications marked as read")),
              );
            },
            tooltip: "Mark all as read",
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(child: Text("No notifications yet"))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationTile(notification: notification);
              },
            ),
    );
  }
}


class NotificationTile extends StatelessWidget {
  final app_notification.Notification notification;

  const NotificationTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getNotificationColor(notification.type),
        child: Icon(_getNotificationIcon(notification.type), color: Colors.white),
      ),
      title: Text(
        _getNotificationTitle(notification),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_getNotificationMessage(notification)),
          const SizedBox(height: 4),
          Text(
            _formatTimestamp(notification.scheduledAt),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      trailing: notification.sentAt == null
          ? Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            )
          : null,
      onTap: () {
        // Handle notification tap
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case "DUE_SOON":
        return Colors.orange;
      case "D_DAY":
        return const Color.fromARGB(255, 16, 119, 222);
      case "PAST_DUE":
        return Colors.red;
      case "DATE_CHANGED":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case "DUE_SOON":
        return Icons.calendar_today;
      case "D_DAY":
        return Icons.monetization_on;
      case "PAST_DUE":
        return Icons.warning;
      case "DATE_CHANGED":
        return Icons.edit_calendar;
      default:
        return Icons.notifications;
    }
  }

  String _getNotificationTitle(app_notification.Notification notification) {
    switch (notification.type) {
      case "DUE_SOON":
        return "Due Date Reminder";
      case "D_DAY":
        return "Payment Due Today";
      case "PAST_DUE":
        return "Payment Overdue";
      case "DATE_CHANGED":
        return "Due Date Changed";
      default:
        return "Notification";
    }
  }

  String _getNotificationMessage(app_notification.Notification notification) {
    final amount = notification.payload["amount"];
    final currency = notification.payload["currency"];
    switch (notification.type) {
      case "DUE_SOON":
        return "Your payment of $amount $currency is due soon.";
      case "D_DAY":
        return "Your payment of $amount $currency is due today.";
      case "PAST_DUE":
        return "Your payment of $amount $currency is overdue.";
      case "DATE_CHANGED":
        return "Your loan due date has changed.";
      default:
        return "You have a new notification.";
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} minutes ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hours ago";
    } else {
      return "${difference.inDays} days ago";
    }
  }
}
