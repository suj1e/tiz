import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../ai/providers/ai_config_provider.dart';
import '../../ai/models/ai_model.dart';
import '../../core/constants.dart';

/// AI Settings Page
/// Independent page for AI configuration with card-based model selection
/// and secure API key input
class AiSettingsPage extends StatefulWidget {
  const AiSettingsPage({super.key});

  @override
  State<AiSettingsPage> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends State<AiSettingsPage> {
  bool _showApiKeySection = false;
  bool _showAdvancedSettings = false;

  // Search/filter
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colors.text,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'AI 设置',
          style: TextStyle(
            color: colors.text,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Model Selection Section
                    _buildSectionTitle(colors, '选择 AI 模型'),
                    const SizedBox(height: 12),
                    _buildModelSearchBar(colors),
                    const SizedBox(height: 12),
                    _buildModelCards(colors),

                    const SizedBox(height: 24),

                    // API Key Section (Collapsible)
                    _buildCollapsibleSection(
                      colors,
                      title: 'API Key 配置',
                      icon: Icons.key_outlined,
                      isExpanded: _showApiKeySection,
                      onTap: () => setState(() => _showApiKeySection = !_showApiKeySection),
                      child: _buildApiKeyContent(colors),
                    ),

                    const SizedBox(height: 24),

                    // Advanced Settings Section (Collapsible)
                    _buildCollapsibleSection(
                      colors,
                      title: '高级设置',
                      icon: Icons.tune_outlined,
                      isExpanded: _showAdvancedSettings,
                      onTap: () => setState(() => _showAdvancedSettings = !_showAdvancedSettings),
                      child: _buildAdvancedSettingsContent(colors),
                    ),
                  ],
                ),
              ),
            ),

            // Fixed bottom save button
            _buildSaveButton(colors),
          ],
        ),
      ),
    );
  }

  /// Build section title
  Widget _buildSectionTitle(ThemeColors colors, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: colors.textTertiary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.05,
        ),
      ),
    );
  }

  /// Build model search bar
  Widget _buildModelSearchBar(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border.all(color: colors.border, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_outlined,
            size: 18,
            color: colors.textTertiary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索模型...',
                hintStyle: TextStyle(color: colors.textTertiary),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                color: colors.text,
                fontSize: 14,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: Icon(
                Icons.clear_rounded,
                size: 18,
                color: colors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }

  /// Build model cards (card-based selector, not dropdown)
  Widget _buildModelCards(ThemeColors colors) {
    return Consumer<AiConfigProvider>(
      builder: (context, aiProvider, child) {
        final selectedModel = aiProvider.model;

        // Filter models based on search
        final filteredModels = AiModel.values.where((model) {
          if (_searchQuery.isEmpty) return true;
          return model.displayName.toLowerCase().contains(_searchQuery) ||
              model.description.toLowerCase().contains(_searchQuery);
        }).toList();

        return Column(
          children: filteredModels.map((model) {
            final isSelected = model == selectedModel;
            return _ModelCard(
              model: model,
              isSelected: isSelected,
              colors: colors,
              onTap: () => _selectModel(model, aiProvider),
            );
          }).toList(),
        );
      },
    );
  }

  /// Build collapsible section
  Widget _buildCollapsibleSection(
    ThemeColors colors, {
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Column(
      children: [
        // Section header
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: colors.text,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 150),
                  turns: isExpanded ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Collapsible content
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: isExpanded
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: child,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  /// Build API Key content
  Widget _buildApiKeyContent(ThemeColors colors) {
    return Consumer<AiConfigProvider>(
      builder: (context, aiProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.bgSecondary,
            border: Border.all(color: colors.border, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current model indicator
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '当前模型: ${aiProvider.model.displayName}',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // API Key status
              _buildApiKeyStatus(colors, aiProvider),

              const SizedBox(height: 12),

              // API Key input
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '输入 API Key...',
                  hintStyle: TextStyle(color: colors.textTertiary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.border, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.border, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.text, width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                style: TextStyle(
                  color: colors.text,
                  fontSize: 13,
                ),
                onSubmitted: (value) => _setApiKey(value, aiProvider),
              ),

              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  if (aiProvider.isApiKeyConfigured)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _clearApiKey(aiProvider),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.text,
                          side: BorderSide(color: colors.border, width: 1),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '清除 Key',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build API Key status indicator
  Widget _buildApiKeyStatus(ThemeColors colors, AiConfigProvider aiProvider) {
    final isConfigured = aiProvider.isApiKeyConfigured;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isConfigured
            ? colors.bgSecondary
            : colors.bg,
        border: Border.all(
          color: isConfigured ? const Color(0xFF22C55E) : colors.border,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isConfigured ? Icons.check_circle_outline : Icons.warning_outlined,
            size: 16,
            color: isConfigured
                ? const Color(0xFF22C55E)
                : colors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            isConfigured ? 'API Key 已配置' : '未配置 API Key',
            style: TextStyle(
              color: isConfigured
                  ? const Color(0xFF22C55E)
                  : colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build advanced settings content
  Widget _buildAdvancedSettingsContent(ThemeColors colors) {
    return Consumer<AiConfigProvider>(
      builder: (context, aiProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.bgSecondary,
            border: Border.all(color: colors.border, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              // Temperature slider (0.0 - 2.0)
              _buildSliderSetting(
                colors,
                label: '温度 (Temperature)',
                value: aiProvider.temperature,
                min: 0.0,
                max: 2.0,
                divisions: 20,
                displayValue: aiProvider.temperature.toStringAsFixed(1),
                description: '控制输出的随机性，值越高越随机',
                onChanged: (value) => _setTemperature(value, aiProvider),
              ),

              const SizedBox(height: 16),

              // Max tokens slider (256 - 8192)
              _buildSliderSetting(
                colors,
                label: '最大 Tokens (Max: ${aiProvider.model.maxTokens})',
                value: aiProvider.maxTokens.toDouble(),
                min: 256,
                max: aiProvider.model.maxTokens.toDouble().clamp(256, 8192),
                divisions: 30,
                displayValue: aiProvider.maxTokens.toString(),
                description: '控制生成的最大 token 数量',
                onChanged: (value) => _setMaxTokens(value.toInt(), aiProvider),
              ),

              const SizedBox(height: 16),

              // Stream output toggle
              _buildFeatureToggle(
                colors,
                label: '流式输出',
                icon: Icons.stream_rounded,
                value: aiProvider.streamOutput,
                description: '实时显示生成内容',
                onChanged: () => aiProvider.toggleStreamOutput(),
              ),

              const SizedBox(height: 8),

              // Deep thinking mode toggle (only for supported models)
              if (aiProvider.model.supportsDeepThinking)
                _buildFeatureToggle(
                  colors,
                  label: '深度思考模式',
                  icon: Icons.psychology_rounded,
                  value: aiProvider.deepThinkingMode,
                  description: '启用扩展推理能力',
                  onChanged: () => aiProvider.toggleDeepThinkingMode(),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Build slider setting
  Widget _buildSliderSetting(
    ThemeColors colors, {
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayValue,
    String? description,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: colors.text,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              displayValue,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: colors.textTertiary,
              fontSize: 11,
            ),
          ),
        ],
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: colors.text,
            inactiveColor: colors.border,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  /// Build feature toggle
  Widget _buildFeatureToggle(
    ThemeColors colors, {
    required String label,
    required IconData icon,
    required bool value,
    String? description,
    required VoidCallback onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.bg,
                border: Border.all(color: colors.border, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: colors.text,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (description != null)
                    Text(
                      description,
                      style: TextStyle(
                        color: colors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onChanged,
              child: Container(
                width: 44,
                height: 24,
                decoration: BoxDecoration(
                  color: value ? colors.accent : colors.border,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 150),
                  alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: colors.bg,
                      shape: BoxShape.circle,
                    ),
                    margin: const EdgeInsets.all(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build fixed bottom save button
  Widget _buildSaveButton(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border(
          top: BorderSide(color: colors.border, width: 1),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _saveAndExit(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.accent,
            foregroundColor: colors.bg,
            elevation: 0,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            '保存设置',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// Select model
  void _selectModel(AiModel model, AiConfigProvider aiProvider) {
    aiProvider.setModel(model);
    setState(() {});
  }

  /// Set API key
  void _setApiKey(String key, AiConfigProvider aiProvider) {
    if (key.trim().isEmpty) return;
    aiProvider.setApiKey(key.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('API Key 已保存'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Clear API key
  void _clearApiKey(AiConfigProvider aiProvider) {
    aiProvider.clearApiKey();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('API Key 已清除'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Set temperature
  void _setTemperature(double value, AiConfigProvider aiProvider) {
    aiProvider.setTemperature(value);
  }

  /// Set max tokens
  void _setMaxTokens(int value, AiConfigProvider aiProvider) {
    aiProvider.setMaxTokens(value);
  }

  /// Save and exit
  void _saveAndExit(BuildContext context) {
    // Config is auto-saved, just navigate back
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('设置已保存'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Model Card Widget
class _ModelCard extends StatelessWidget {
  final AiModel model;
  final bool isSelected;
  final ThemeColors colors;
  final VoidCallback onTap;

  const _ModelCard({
    required this.model,
    required this.isSelected,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? colors.bgSecondary : colors.bg,
          border: Border.all(
            color: isSelected ? colors.text : colors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Model icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.bgSecondary,
                border: Border.all(color: colors.border, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  model.icon,
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Model info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.displayName,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    model.description,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: colors.text,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: colors.bg,
                  size: 16,
                ),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: colors.bgSecondary,
                  border: Border.all(color: colors.border, width: 1),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
