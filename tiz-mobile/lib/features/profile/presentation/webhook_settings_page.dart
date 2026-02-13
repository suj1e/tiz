import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/webhook.dart';
import '../profile_provider.dart';

class WebhookSettingsPage extends ConsumerWidget {
  const WebhookSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final webhooksAsync = ref.watch(webhookNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Webhook配置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddWebhookDialog(context, ref),
          ),
        ],
      ),
      body: webhooksAsync.when(
        data: (webhooks) {
          if (webhooks.isEmpty) {
            return const Center(
              child: Text('暂无Webhook配置\n点击右上角添加'),
            );
          }
          return ListView.builder(
            itemCount: webhooks.length,
            itemBuilder: (context, index) {
              final webhook = webhooks[index];
              return _WebhookListItem(webhook: webhook);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWebhookDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddWebhookDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _WebhookDialog(
        onSave: (url, name) {
          ref.read(webhookNotifierProvider.notifier).addWebhook(
                url: url,
                name: name,
              );
        },
      ),
    );
  }
}

class _WebhookListItem extends ConsumerWidget {
  final Webhook webhook;

  const _WebhookListItem({required this.webhook});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.webhook),
      title: Text(webhook.name),
      subtitle: Text(
        webhook.url,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            _showEditDialog(context, ref);
          } else if (value == 'delete') {
            _showDeleteConfirmDialog(context, ref);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: ListTile(
              leading: Icon(Icons.edit),
              title: Text('编辑'),
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('删除', style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _WebhookDialog(
        initialUrl: webhook.url,
        initialName: webhook.name,
        onSave: (url, name) {
          ref.read(webhookNotifierProvider.notifier).updateWebhook(
                webhook.copyWith(url: url, name: name),
              );
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 "${webhook.name}" 吗?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              ref.read(webhookNotifierProvider.notifier).deleteWebhook(webhook.id);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _WebhookDialog extends StatefulWidget {
  final String? initialUrl;
  final String? initialName;
  final void Function(String url, String name) onSave;

  const _WebhookDialog({
    this.initialUrl,
    this.initialName,
    required this.onSave,
  });

  @override
  State<_WebhookDialog> createState() => _WebhookDialogState();
}

class _WebhookDialogState extends State<_WebhookDialog> {
  late final TextEditingController _urlController;
  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.initialUrl);
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialUrl == null ? '添加Webhook' : '编辑Webhook'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '名称',
                hintText: '例如: 生产环境通知',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'https://example.com/webhook',
              ),
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入URL';
                }
                final uri = Uri.tryParse(value);
                if (uri == null || !uri.hasScheme) {
                  return '请输入有效的URL';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(_urlController.text, _nameController.text);
              Navigator.pop(context);
            }
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
