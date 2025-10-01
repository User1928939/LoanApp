import 'package:flutter/foundation.dart';
import 'contacts_service.dart';
import 'hedera_service.dart';
import 'loan_service.dart';
import 'navigation_service.dart';
import 'notification_service.dart';


class ServiceLocator {
  
  // Singleton pattern
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Services
  late LoanService loanService;
  late ContactsService contactsService;
  late NotificationService notificationService;
  late HederaService hederaService;
  late NavigationService navigationService;
  // Initialize services
  void setupServices() {
    try {
      debugPrint('Initializing AuthService');

      debugPrint('Initializing LoanService');
      loanService = ApiLoanService();

      debugPrint('Initializing ContactsService');
      contactsService = PhoneContactsService();

      debugPrint('Initializing NotificationService');
      notificationService = ApiNotificationService();

      debugPrint('Initializing HederaService');
      hederaService = MockHederaService();

      debugPrint('Initializing NavigationService');
      navigationService = NavigationService();

      debugPrint('All services initialized successfully');
    } catch (e) {
      debugPrint('Error setting up services: $e');
      rethrow; // Re-throw to be caught in main()
    }
  }
}

// Global instance for easy access throughout the app
final serviceLocator = ServiceLocator();
