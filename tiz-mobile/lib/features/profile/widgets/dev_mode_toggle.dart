import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/mock_config.dart';
import '../../../core/services/service_locator.dart';

/// Developer mode toggle widget
class DevModeToggle extends StatelessWidget {
  const DevModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MockConfig>(
      builder: (context, mockConfig, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.science_outlined),
              title: const Text('Mock Mode'),
              subtitle: Text(
                mockConfig.isMockMode
                    ? 'Using local mock data'
                    : 'Using real API',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: mockConfig.isMockMode,
              onChanged: (value) => _showConfirmDialog(context, mockConfig),
            ),
            if (mockConfig.isMockMode)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                child: Text(
                  'Mock login: ${_getMockCredentials()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontFamily: 'monospace',
                      ),
                ),
              ),
          ],
        );
      },
    );
  }

  String _getMockCredentials() {
    return 'test@test.com / password123';
  }

  void _showConfirmDialog(BuildContext context, MockConfig mockConfig) {
    final newValue = !mockConfig.isMockMode;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(newValue ? 'Enable Mock Mode?' : 'Disable Mock Mode?'),
        content: Text(
          newValue
              ? 'Will use local mock data, no backend required. Requires app restart to take full effect.'
              : 'Will switch to real API requests. Requires app restart to take full effect.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              mockConfig.setMockMode(newValue);
              Navigator.pop(dialogContext);

              // Reinitialize repositories
              await ServiceLocator.reinitializeRepositories();

              // Show notification
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mock mode changed, please restart app'),
                  ),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
