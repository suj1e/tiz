import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../../core/routes.dart';

/// Splash Screen
/// App logo/icon in center, app name "Tiz" below logo
/// 2 seconds delay, then navigate to login (or home if logged in)
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // TODO: Check if user is logged in
    // For now, navigate to MainNavigation (explore page)
    Navigator.pushReplacementNamed(context, '/explore');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Scaffold(
      backgroundColor: colors.bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo container with bgSecondary background
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colors.bgSecondary,
                border: Border.all(color: colors.border, width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.language_rounded,
                color: colors.text,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            // App name
            Text(
              'Tiz',
              style: TextStyle(
                color: colors.text,
                fontSize: 32,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
