import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../domain/language.dart';
import 'translation_controller.dart';

class TranslationPage extends ConsumerStatefulWidget {
  const TranslationPage({super.key});

  @override
  ConsumerState<TranslationPage> createState() => _TranslationPageState();
}

class _TranslationPageState extends ConsumerState<TranslationPage> {
  final _textController = TextEditingController();
  Language _targetLanguage = Language.en;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleTranslate() async {
    final text = _textController.text;
    await ref.read(translationControllerProvider.notifier).detectAndTranslate(
          text: text,
          targetLanguage: _targetLanguage,
        );
  }

  void _handleReset() {
    _textController.clear();
    ref.read(translationControllerProvider.notifier).reset();
  }

  Future<void> _handleCopy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard')),
      );
    }
  }

  void _handleShare(String text) {
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(translationControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('翻译'),
        actions: [
          if (state is TranslationSuccess || _textController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _handleReset,
              tooltip: 'Clear',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Target Language Selector
            _buildLanguageSelector(),
            const SizedBox(height: 16),

            // Input Area
            _buildInputArea(),
            const SizedBox(height: 16),

            // Translate Button
            _buildTranslateButton(state),
            const SizedBox(height: 16),

            // Output Area
            _buildOutputArea(state),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Text('Target Language: '),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<Language>(
                value: _targetLanguage,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                items: Language.values.map((lang) {
                  return DropdownMenuItem(
                    value: lang,
                    child: Text('${lang.label} (${lang.code})'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _targetLanguage = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Input',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter text to translate...',
                border: InputBorder.none,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslateButton(TranslationState state) {
    final isLoading = state is TranslationDetecting || state is TranslationTranslating;
    final canTranslate = _textController.text.trim().isNotEmpty && !isLoading;

    return FilledButton.icon(
      onPressed: canTranslate ? _handleTranslate : null,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.translate),
      label: Text(isLoading ? 'Translating...' : 'Translate'),
    );
  }

  Widget _buildOutputArea(TranslationState state) {
    if (state is TranslationIdle) {
      return const SizedBox.shrink();
    }

    if (state is TranslationError) {
      return Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is TranslationSuccess) {
      final result = state.result;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Result',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  // Detected language badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${result.detectedSourceLanguage.label} -> ${result.targetLanguage.label}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SelectableText(
                result.translatedText,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _handleCopy(result.translatedText),
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _handleShare(result.translatedText),
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Loading states
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                state is TranslationDetecting
                    ? 'Detecting language...'
                    : 'Translating...',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
