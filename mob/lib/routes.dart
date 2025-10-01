import 'package:flutter/material.dart';
import 'login_page.dart';
import 'screens/dashboard_screen.dart';
import 'screens/create_loan_screen.dart';
import 'screens/loan_details_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'welcome_screen.dart';
import 'screens/friends_screen.dart';
import './services/UserSession.dart';
import 'screens/history_screen.dart';
import 'models/loan.dart';


// Define route names as constants
class Routes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String createLoan = '/create-loan';
  static const String loanDetails = '/loan-details';
  static const String notifications = '/notifications';
  static const String friends = '/friends';
  static const String profile = '/profile';
  static const String history = '/history';
}

// Define route generator
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case Routes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case Routes.createLoan:
  final userId = settings.arguments as int; // 👈 expect userId here
  return MaterialPageRoute(
    builder: (_) => CreateLoanScreen(userId: userId),
  );


      case Routes.loanDetails:
        final loan = settings.arguments as Loan;
        return MaterialPageRoute(
          builder: (_) => LoanDetailsScreen(loan: loan),
        );

      case Routes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case Routes.history:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());

      case Routes.friends:
return MaterialPageRoute(
    builder: (_) => FriendsScreen(userId: UserSession.id!),
  );
      case Routes.profile:
        return MaterialPageRoute(builder: (_) =>  ProfileScreen());

      default:
        // If the route is not recognized, show an error page
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
