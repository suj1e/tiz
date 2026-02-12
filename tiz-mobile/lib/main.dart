import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants.dart';
import 'features/auth/login_page.dart';
import 'features/auth/auth_controller.dart';
import 'features/splash/splash_page.dart';
import 'features/profile/personal_info_page.dart';
import 'features/profile/privacy_page.dart';
import 'features/settings/settings_page.dart';
import 'features/about/about_page.dart';
import 'features/ai_settings/ai_settings_page.dart';
import 'theme/theme_provider.dart';
import 'providers/notification_provider.dart';
import 'ai/providers/ai_config_provider.dart';
import 'commands/providers/command_provider.dart';
import 'widgets/navigation/main_navigation.dart';
import 'features/translation/models/favorite_translation.dart';
import 'features/translation/providers/favorites_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(FavoriteTranslationAdapter());

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const TizApp());
}

class TizApp extends StatelessWidget {
  const TizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => AiConfigProvider()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => CommandProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()..init()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme,
            home: const SplashPage(),
            routes: {
              '/login': (context) => const LoginPage(),
              '/explore': (context) => const MainNavigation(),
              '/personal-info': (context) => const PersonalInfoPage(),
              '/privacy': (context) => const PrivacyPage(),
              '/settings': (context) => const SettingsPage(),
              '/about': (context) => const AboutPage(),
              '/ai-settings': (context) => const AiSettingsPage(),
            },
          );
        },
      ),
    );
  }
}
