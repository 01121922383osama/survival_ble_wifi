import 'package:flutter/material.dart';
import 'package:survival/core/theme/theme.dart'; // Import theme

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Example notification data structure
  final List<Map<String, dynamic>> _allNotifications = [
    // Add example notifications here later
    // { 'id': 1, 'title': 'Fall Detected', 'body': 'Fall detected in Living Room at 10:35 AM', 'timestamp': DateTime.now().subtract(Duration(minutes: 10)), 'read': false, 'resolved': false },
    // { 'id': 2, 'title': 'Device Offline', 'body': 'Radar Sensor Beta went offline.', 'timestamp': DateTime.now().subtract(Duration(hours: 1)), 'read': true, 'resolved': false },
    // { 'id': 3, 'title': 'Low Battery', 'body': 'Radar Sensor Alpha battery is low (15%).', 'timestamp': DateTime.now().subtract(Duration(days: 1)), 'read': true, 'resolved': true },
  ];

  @override
  void initState() {
    super.initState();
    // Assuming 3 tabs: All, Unread, Resolved
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter notifications based on tab (Example logic)
    List<Map<String, dynamic>> unreadNotifications = _allNotifications
        .where((n) => !n['read'])
        .toList();
    List<Map<String, dynamic>> resolvedNotifications = _allNotifications
        .where((n) => n['resolved'])
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          // Optional: Add action like 'Mark all as read' or 'Clear all'
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear Resolved',
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: lightTextColor, // Use theme color
          labelColor: lightTextColor,
          unselectedLabelColor: lightTextColor.withValues(alpha: 0.7),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unread'), // Or 'Active'
            Tab(text: 'Resolved'), // Or 'Archived'
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList(_allNotifications, 'All'),
          _buildNotificationList(unreadNotifications, 'Unread'),
          _buildNotificationList(resolvedNotifications, 'Resolved'),
        ],
      ),
    );
  }

  Widget _buildNotificationList(
    List<Map<String, dynamic>> notifications,
    String tabName,
  ) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${tabName.toLowerCase()} notifications',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return ListTile(
          leading: Icon(
            _getNotificationIcon(notification['title']),
            color: notification['read'] ? Colors.grey : primaryColor,
          ),
          title: Text(
            notification['title'],
            style: TextStyle(
              fontWeight: notification['read']
                  ? FontWeight.normal
                  : FontWeight.bold,
            ),
          ),
          subtitle: Text(notification['body']),
          trailing: Text(
            _formatTimestamp(notification['timestamp']),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onTap: () {},
        );
      },
    );
  }

  IconData _getNotificationIcon(String title) {
    if (title.toLowerCase().contains('fall')) {
      return Icons.warning_amber_rounded;
    }
    if (title.toLowerCase().contains('offline')) {
      return Icons.signal_wifi_off_outlined;
    }
    if (title.toLowerCase().contains('battery')) {
      return Icons.battery_alert_outlined;
    }
    return Icons.notifications;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
