import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/preferences.dart';
import 'data/webhook_repository.dart';
import 'domain/user_profile.dart';
import 'domain/webhook.dart';

/// Provider for user profile (currently mock)
final userProfileProvider = Provider<UserProfile>((ref) {
  return UserProfile.mock();
});

/// Provider for webhook repository
final webhookRepositoryProvider = Provider<WebhookRepository>((ref) {
  final asyncPrefs = ref.watch(preferencesProvider);
  return asyncPrefs.when(
    data: (prefs) => PreferencesWebhookRepository(
      getWebhooksJson: () => prefs.getWebhooks(),
      setWebhooksJson: (list) => prefs.setWebhooks(list),
    ),
    loading: () => PreferencesWebhookRepository(
      getWebhooksJson: () => [],
      setWebhooksJson: (_) async {},
    ),
    error: (_, __) => PreferencesWebhookRepository(
      getWebhooksJson: () => [],
      setWebhooksJson: (_) async {},
    ),
  );
});

/// Provider for all webhooks
final webhooksProvider = FutureProvider<List<Webhook>>((ref) async {
  final repository = ref.watch(webhookRepositoryProvider);
  return repository.getWebhooks();
});

/// Notifier for managing webhooks
final webhookNotifierProvider =
    StateNotifierProvider<WebhookNotifier, AsyncValue<List<Webhook>>>((ref) {
  return WebhookNotifier(ref);
});

class WebhookNotifier extends StateNotifier<AsyncValue<List<Webhook>>> {
  final Ref _ref;

  WebhookNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadWebhooks();
  }

  Future<void> _loadWebhooks() async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(webhookRepositoryProvider);
      final webhooks = await repository.getWebhooks();
      state = AsyncValue.data(webhooks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addWebhook({required String url, required String name}) async {
    try {
      final repository = _ref.read(webhookRepositoryProvider);
      final webhook = await repository.addWebhook(url: url, name: name);
      state = AsyncValue.data([...state.value ?? [], webhook]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateWebhook(Webhook webhook) async {
    try {
      final repository = _ref.read(webhookRepositoryProvider);
      await repository.updateWebhook(webhook);
      final webhooks = state.value ?? [];
      final index = webhooks.indexWhere((w) => w.id == webhook.id);
      if (index != -1) {
        final newList = [...webhooks];
        newList[index] = webhook;
        state = AsyncValue.data(newList);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteWebhook(String id) async {
    try {
      final repository = _ref.read(webhookRepositoryProvider);
      await repository.deleteWebhook(id);
      state = AsyncValue.data(
        (state.value ?? []).where((w) => w.id != id).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
