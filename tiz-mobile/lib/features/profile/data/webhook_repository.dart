import 'dart:convert';
import '../domain/webhook.dart';

/// Abstract repository for webhook operations
abstract class WebhookRepository {
  /// Get all webhooks
  Future<List<Webhook>> getWebhooks();

  /// Get a webhook by ID
  Future<Webhook?> getWebhook(String id);

  /// Add a new webhook
  Future<Webhook> addWebhook({required String url, required String name});

  /// Update an existing webhook
  Future<Webhook> updateWebhook(Webhook webhook);

  /// Delete a webhook
  Future<void> deleteWebhook(String id);
}

/// In-memory implementation using Preferences storage
class PreferencesWebhookRepository implements WebhookRepository {
  final List<String> Function() _getWebhooksJson;
  final Future<void> Function(List<String>) _setWebhooksJson;

  List<Webhook>? _cache;

  PreferencesWebhookRepository({
    required List<String> Function() getWebhooksJson,
    required Future<void> Function(List<String>) setWebhooksJson,
  })  : _getWebhooksJson = getWebhooksJson,
        _setWebhooksJson = setWebhooksJson;

  List<Webhook> _loadFromStorage() {
    if (_cache != null) return _cache!;
    final jsonList = _getWebhooksJson();
    _cache = jsonList.map((json) {
      return Webhook.fromJson(jsonDecode(json) as Map<String, dynamic>);
    }).toList();
    return _cache!;
  }

  Future<void> _saveToStorage() async {
    if (_cache == null) return;
    final jsonList = _cache!.map((w) => jsonEncode(w.toJson())).toList();
    await _setWebhooksJson(jsonList);
  }

  @override
  Future<List<Webhook>> getWebhooks() async {
    return _loadFromStorage();
  }

  @override
  Future<Webhook?> getWebhook(String id) async {
    final webhooks = _loadFromStorage();
    return webhooks.cast<Webhook?>().firstWhere(
          (w) => w?.id == id,
          orElse: () => null,
        );
  }

  @override
  Future<Webhook> addWebhook({required String url, required String name}) async {
    final webhooks = _loadFromStorage();
    final webhook = Webhook(
      id: 'webhook-${DateTime.now().millisecondsSinceEpoch}',
      url: url,
      name: name,
      createdAt: DateTime.now(),
    );
    _cache = [...webhooks, webhook];
    await _saveToStorage();
    return webhook;
  }

  @override
  Future<Webhook> updateWebhook(Webhook webhook) async {
    final webhooks = _loadFromStorage();
    final index = webhooks.indexWhere((w) => w.id == webhook.id);
    if (index == -1) {
      throw Exception('Webhook not found: ${webhook.id}');
    }
    _cache = [...webhooks];
    _cache![index] = webhook;
    await _saveToStorage();
    return webhook;
  }

  @override
  Future<void> deleteWebhook(String id) async {
    final webhooks = _loadFromStorage();
    _cache = webhooks.where((w) => w.id != id).toList();
    await _saveToStorage();
  }
}
