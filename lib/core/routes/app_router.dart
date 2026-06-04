import 'package:offline_data_transfer/core/app/views/landing_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // --- Route Constants ---
  static const String initial = "/";
  static const String onBoarding = "/onboarding";
  static const String login = "/login";
  static const String register = "/register";
  static const String home = "/home";

  /// The standard Flutter "Switchboard" for navigation
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initial:
        return MaterialPageRoute(builder: (_) => const LandingScreen());

      // case login:
      //   return MaterialPageRoute(builder: (_) => const LoginScreen());

      default:
        return _errorRoute(settings.name);
    }
  }

  static Route<dynamic> _errorRoute(String? name) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text("Route Error")),
        body: Center(child: Text("No route defined for: $name")),
      ),
    );
  }
}
