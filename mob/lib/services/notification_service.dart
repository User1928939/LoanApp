import '../models/notification.dart';


abstract class NotificationService {
  Future<List<Notification>> getNotifications(int userId);
  Future<void> markAsRead(int notificationId);
  Future<void> markAllAsRead(int userId);
  Future<void> sendLoanRequestNotification(
    int userId,
    int loanId,
    double amount,
  );
  Future<void> sendDueDateReminderNotification(
    int userId,
    int loanId,
    DateTime dueDate,
  );
  Future<void> sendOverdueNotification(
    int userId,
    int loanId,
    double amount,
  );
  Stream<List<Notification>> watchNotifications(int userId);
}


class ApiNotificationService implements NotificationService {
  // This would be implemented with API calls to your backend
  // For now, we'll provide mock implementations

  @override
  Future<List<Notification>> getNotifications(int userId) async {
    // Mock implementation
    return Future.delayed(
      const Duration(seconds: 1),
      () => [
        Notification(
          id: 1,
          loanId: 101,
          type: 'DUE_SOON',
          scheduledAt: DateTime.now().add(const Duration(days: 3)),
          sentAt: null,
          payload: {'amount': 100.0, 'currency': 'MAD'},
        ),
        Notification(
          id: 2,
          loanId: 102,
          type: 'D_DAY',
          scheduledAt: DateTime.now(),
          sentAt: DateTime.now(),
          payload: {'amount': 50.0, 'currency': 'USD'},
        ),
      ],
    );
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    // Mock implementation
    return Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> markAllAsRead(int userId) async {
    // Mock implementation
    return Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> sendLoanRequestNotification(
    int userId,
    int loanId,
    double amount,
  ) async {
    // Mock implementation
    return Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> sendDueDateReminderNotification(
    int userId,
    int loanId,
    DateTime dueDate,
  ) async {
    // Mock implementation
    return Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> sendOverdueNotification(
    int userId,
    int loanId,
    double amount,
  ) async {
    // Mock implementation
    return Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Stream<List<Notification>> watchNotifications(int userId) {
    // Mock implementation
    return Stream.periodic(
      const Duration(seconds: 30),
      (_) => [
        Notification(
          id: 1,
          loanId: 101,
          type: 'DUE_SOON',
          scheduledAt: DateTime.now().add(const Duration(days: 3)),
          sentAt: null,
          payload: {'amount': 100.0, 'currency': 'MAD'},
        ),
      ],
    );
  }
}
