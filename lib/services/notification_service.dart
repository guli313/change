class NotificationService {
  static final List<Map<String, String>> _notifications = [
    {
      'title': 'Welcome to Roommate Finder',
      'subtitle': 'Notifications are ready',
      'body':
          'Tap the notification bell anytime to see the latest posts from other users.',
    },
  ];

  static List<Map<String, String>> get notifications =>
      List.unmodifiable(_notifications);

  static void addNotification({
    required String title,
    required String subtitle,
    required String body,
  }) {
    _notifications.insert(0, {
      'title': title,
      'subtitle': subtitle,
      'body': body,
    });
  }

  static void clearNotifications() {
    _notifications.clear();
  }
}
