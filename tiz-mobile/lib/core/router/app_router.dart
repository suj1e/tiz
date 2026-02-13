import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/discovery/presentation/discovery_page.dart';
import '../../features/discovery/presentation/quiz_placeholder_page.dart';
import '../../features/message/presentation/message_detail_shell_page.dart';
import '../../features/message/presentation/message_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../shared/widgets/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/discover',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/messages',
                builder: (context, state) => const MessagePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/discover',
                builder: (context, state) => const DiscoveryPage(),
                routes: [
                  GoRoute(
                    path: 'quiz',
                    builder: (context, state) => const QuizPlaceholderPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      // Message detail route (outside shell for full-screen view)
      GoRoute(
        path: '/messages/:messageId',
        builder: (context, state) => const MessageDetailShellPage(),
      ),
    ],
  );
});
