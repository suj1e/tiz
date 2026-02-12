import 'package:flutter/material.dart';

import '../features/explore/explore_page.dart';
import '../features/profile/profile_page.dart';
import '../features/splash/splash_page.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/settings/settings_page.dart';
import '../features/about/about_page.dart';

/// App Route Names
class RouteNames {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String explore = '/';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String about = '/about';
}

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case RouteNames.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case RouteNames.explore:
      case '/explore': // Backwards compatibility
        return MaterialPageRoute(builder: (_) => const ExplorePage());
      case RouteNames.profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case RouteNames.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case RouteNames.about:
        return MaterialPageRoute(builder: (_) => const AboutPage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
