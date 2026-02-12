import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../core/constants.dart';
import '../../commands/providers/command_provider.dart';

/// Bot Page - AI Assistant Interface
/// Unified chat and command interface with Claude CLI-style design
/// Features:
/// - Unified message stream (chat messages + command executions)
/// - Command execution status with progress indicators
/// - System messages for command completion/failure
/// - Clean distinction between chat and command interactions
class BotPage extends StatefulWidget {
  const BotPage({super.key});

  @override
  State<BotPage> createState() => BotPageState();
}

/// Expose state type for external access (e.g., from MainNavigation)
class BotPageState extends State<BotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isProcessing = false;
  bool _isScrolling = false;

  // Unified message stream
  final List<BotMessage> _messages = [
    BotMessage.system(
      text: 'Tiz Bot 已就绪。你可以提问或输入指令（以 / 开头）。',
      timestamp: DateTime.now(),
    ),
    BotMessage.chat(
      text: '你好！有什么可以帮你的吗？',
      isUser: false,
      timestamp: DateTime.now(),
    ),
    BotMessage.chat(
      text: '如何提高翻译准确度？',
      isUser: true,
      timestamp: DateTime.now(),
    ),
    BotMessage.chat(
      text: '建议使用 AI 增强翻译模式，它可以理解上下文和语境。',
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  // Active command execution
  ActiveCommand? _activeCommand;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and mode indicator
              _buildHeader(colors),

              const SizedBox(height: 16),

              // Quick command suggestions
              _buildCommandSuggestions(colors),

              const SizedBox(height: 12),

              // Recent Commands Banner (from CommandProvider)
              _RecentCommandsBanner(colors: colors),

              const SizedBox(height: 12),

              // Active command execution panel (if any)
              if (_activeCommand != null) ...[
                _buildActiveCommandPanel(colors),
                const SizedBox(height: 12),
              ],

              // Message Stream
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageItem(_messages[index], colors);
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Input Area
              _buildInputArea(colors),
            ],
          ),
        ),
      ),
    );
  }

  /// Build header
  Widget _buildHeader(ThemeColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Bot',
          style: TextStyle(
            color: colors.text,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        _ModeIndicator(colors: colors),
      ],
    );
  }

  /// Build command suggestions chips
  Widget _buildCommandSuggestions(ThemeColors colors) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _SuggestionChip(
          label: '/quiz',
          hint: '开始测验',
          colors: colors,
          onTap: () => _insertCommand('/quiz'),
        ),
        _SuggestionChip(
          label: '/translate',
          hint: '翻译',
          colors: colors,
          onTap: () => _insertCommand('/translate '),
        ),
        _SuggestionChip(
          label: '/plan',
          hint: '学习计划',
          colors: colors,
          onTap: () => _insertCommand('/plan'),
        ),
      ],
    );
  }

  /// Build active command execution panel
  Widget _buildActiveCommandPanel(ThemeColors colors) {
    if (_activeCommand == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        border: Border.all(color: colors.border, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.text),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _activeCommand!.command,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _activeCommand!.currentStep,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: _activeCommand!.progress,
            backgroundColor: colors.border,
            valueColor: AlwaysStoppedAnimation<Color>(colors.text),
          ),
        ],
      ),
    );
  }

  /// Build message item based on type
  Widget _buildMessageItem(BotMessage message, ThemeColors colors) {
    switch (message.type) {
      case MessageType.chat:
        return _buildChatMessage(message as ChatMessage, colors);
      case MessageType.command:
        return _buildCommandMessage(message as CommandMessage, colors);
      case MessageType.system:
        return _buildSystemMessage(message as SystemMessage, colors);
    }
  }

  /// Build chat message bubble
  Widget _buildChatMessage(ChatMessage message, ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 280),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: message.isUser ? colors.accent : colors.bgSecondary,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(message.isUser ? 12 : 4),
              bottomRight: Radius.circular(message.isUser ? 4 : 12),
            ),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: message.isUser ? colors.bg : colors.text,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  /// Build command message with status
  Widget _buildCommandMessage(CommandMessage message, ThemeColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        border: Border.all(color: colors.border, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Command header with status
          Row(
            children: [
              Icon(
                _getCommandIcon(message.status),
                size: 14,
                color: _getStatusColor(message.status, colors),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message.command,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              Text(
                _getStatusText(message.status),
                style: TextStyle(
                  color: _getStatusColor(message.status, colors),
                  fontSize: 11,
                fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          if (message.output != null) ...[
            const SizedBox(height: 10),
            // Output with bullet point style
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: colors.text,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message.output!,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (message.status == CommandStatus.running) ...[
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: message.progress,
              backgroundColor: colors.border,
              valueColor: AlwaysStoppedAnimation<Color>(colors.text),
            ),
          ],
        ],
      ),
    );
  }

  /// Build system message
  Widget _buildSystemMessage(SystemMessage message, ThemeColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        border: Border.all(color: colors.border, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 14,
            color: colors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message.text,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build input area
  Widget _buildInputArea(ThemeColors colors) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: '输入消息或指令（以 / 开头）...',
              hintStyle: TextStyle(color: colors.textTertiary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.border, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.border, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.text, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
            style: TextStyle(
              color: colors.text,
              fontSize: 14,
            ),
            onSubmitted: (text) => _handleSubmit(text),
          ),
        ),
        const SizedBox(width: 8),
        _SendButton(
          onPressed: _isProcessing ? null : () => _handleSubmit(_controller.text),
          colors: colors,
        ),
      ],
    );
  }

  /// Handle user input submission
  void _handleSubmit(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _controller.clear();
      _isProcessing = true;
    });

    if (text.startsWith('/')) {
      // Command input
      _executeCommand(text);
    } else {
      // Chat message
      _sendChatMessage(text);
    }
  }

  /// Send chat message
  void _sendChatMessage(String text) {
    setState(() {
      _messages.add(BotMessage.chat(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _messages.add(BotMessage.chat(
            text: '这是 AI 的回复占位符。实际使用时需要连接 AI 服务。',
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    });
  }

  /// Execute command
  void _executeCommand(String command) {
    final commandProvider = context.read<CommandProvider>();

    // Start command via provider
    commandProvider.startCommand(command);

    // Add command message with running status
    final cmdMessage = BotMessage.command(
      command: command,
      status: CommandStatus.running,
      progress: 0.0,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(cmdMessage);
      _activeCommand = ActiveCommand(
        command: command,
        currentStep: '正在初始化...',
        progress: 0.0,
      );
    });

    _scrollToBottom();

    // Simulate command execution
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return false;

      final newProgress = (_activeCommand!.progress + 0.25).clamp(0.0, 1.0);
      final stepIndex = (newProgress * 4).toInt();

      final steps = [
        '正在初始化...',
        '正在分析指令...',
        '正在执行...',
        '正在完成...',
      ];

      // Get current task from provider
      final currentTask = commandProvider.activeTask;

      setState(() {
        _activeCommand = ActiveCommand(
          command: command,
          currentStep: stepIndex < steps.length ? steps[stepIndex] : '完成',
          progress: newProgress,
        );

        // Update provider progress
        if (currentTask != null) {
          commandProvider.updateProgress(
            currentTask.id,
            newProgress,
            stepIndex < steps.length ? steps[stepIndex] : '完成',
          );
        }

        // Update message progress
        final msgIndex = _messages.indexWhere((m) =>
            m.type == MessageType.command &&
            (m as CommandMessage).command == command &&
            m.status == CommandStatus.running);

        if (msgIndex >= 0) {
          _messages[msgIndex] = BotMessage.command(
            command: command,
            status: newProgress >= 1.0 ? CommandStatus.completed : CommandStatus.running,
            output: newProgress >= 1.0 ? '指令执行完成' : null,
            progress: newProgress,
            timestamp: DateTime.now(),
          );
        }
      });

      return newProgress < 1.0;
    }).then((_) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _activeCommand = null;

          // Add system message
          _messages.add(BotMessage.system(
            text: '$command 已完成',
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();

        // Complete command in provider
        if (commandProvider.activeTask != null) {
          commandProvider.completeCommand(
            commandProvider.activeTask!.id,
            result: '指令执行完成',
          );
        }
      }
    });
  }

  /// Insert command into input field
  void _insertCommand(String command) {
    _controller.text = command;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: command.length),
    );
  }

  /// Scroll to bottom of messages (with guard to prevent concurrent animations)
  void _scrollToBottom() {
    if (_isScrolling) return;
    _isScrolling = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && mounted) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        ).then((_) {
          // Reset flag after animation completes
          if (mounted) {
            Future.delayed(const Duration(milliseconds: 200), () {
              _isScrolling = false;
            });
          }
        });
      } else {
        _isScrolling = false;
      }
    });
  }

  /// Get command status icon
  IconData _getCommandIcon(CommandStatus status) {
    switch (status) {
      case CommandStatus.pending:
        return Icons.schedule_outlined;
      case CommandStatus.running:
        return Icons.pending_outlined;
      case CommandStatus.completed:
        return Icons.check_circle_outline;
      case CommandStatus.failed:
        return Icons.error_outline;
    }
  }

  /// Get status color
  Color _getStatusColor(CommandStatus status, ThemeColors colors) {
    switch (status) {
      case CommandStatus.pending:
        return colors.textSecondary;
      case CommandStatus.running:
        return colors.text;
      case CommandStatus.completed:
        return const Color(0xFF22C55E); // Green
      case CommandStatus.failed:
        return const Color(0xFFEF4444); // Red
    }
  }

  /// Get status text
  String _getStatusText(CommandStatus status) {
    switch (status) {
      case CommandStatus.pending:
        return '等待中';
      case CommandStatus.running:
        return '执行中';
      case CommandStatus.completed:
        return '完成';
      case CommandStatus.failed:
        return '失败';
    }
  }
}

/// Mode indicator widget with chat and terminal icons
class _ModeIndicator extends StatelessWidget {
  final ThemeColors colors;

  const _ModeIndicator({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        border: Border.all(color: colors.border, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 12,
            color: colors.textSecondary,
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_forward,
            size: 10,
            color: colors.textTertiary,
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.terminal_outlined,
            size: 12,
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }
}

/// Suggestion chip widget
class _SuggestionChip extends StatefulWidget {
  final String label;
  final String hint;
  final ThemeColors colors;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.label,
    required this.hint,
    required this.colors,
    required this.onTap,
  });

  @override
  State<_SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<_SuggestionChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.colors.bgSecondary,
            border: Border.all(color: widget.colors.border, width: 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.colors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 4),
              Text(
                widget.hint,
                style: TextStyle(
                  color: widget.colors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Send button widget
class _SendButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final ThemeColors colors;

  const _SendButton({
    required this.onPressed,
    required this.colors,
  });

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => _scaleController.forward() : null,
      onTapUp: widget.onPressed != null
          ? (_) {
              _scaleController.reverse();
              widget.onPressed!();
            }
          : null,
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: widget.onPressed != null
                ? widget.colors.accent
                : widget.colors.border,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.send_rounded,
            color: widget.onPressed != null
                ? widget.colors.bg
                : widget.colors.textTertiary,
            size: 16,
          ),
        ),
      ),
    );
  }
}

/// Message type enum
enum MessageType { chat, command, system }

/// Base message class
abstract class BotMessage {
  final MessageType type;
  final DateTime timestamp;

  BotMessage({required this.type, required this.timestamp});

  factory BotMessage.chat({
    required String text,
    required bool isUser,
    required DateTime timestamp,
  }) => ChatMessage(text: text, isUser: isUser, timestamp: timestamp);

  factory BotMessage.command({
    required String command,
    required CommandStatus status,
    String? output,
    double progress = 0.0,
    required DateTime timestamp,
  }) => CommandMessage(
    command: command,
    status: status,
    output: output,
    progress: progress,
    timestamp: timestamp,
  );

  factory BotMessage.system({
    required String text,
    required DateTime timestamp,
  }) => SystemMessage(text: text, timestamp: timestamp);
}

/// Chat message
class ChatMessage extends BotMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
    required DateTime timestamp,
  }) : super(type: MessageType.chat, timestamp: timestamp);
}

/// Command message
class CommandMessage extends BotMessage {
  final String command;
  final CommandStatus status;
  final String? output;
  final double progress;

  CommandMessage({
    required this.command,
    required this.status,
    this.output,
    this.progress = 0.0,
    required DateTime timestamp,
  }) : super(type: MessageType.command, timestamp: timestamp);
}

/// System message
class SystemMessage extends BotMessage {
  final String text;

  SystemMessage({
    required this.text,
    required DateTime timestamp,
  }) : super(type: MessageType.system, timestamp: timestamp);
}

/// Active command state
class ActiveCommand {
  final String command;
  final String currentStep;
  final double progress;

  ActiveCommand({
    required this.command,
    required this.currentStep,
    required this.progress,
  });
}

/// Recent Commands Banner Widget
/// Shows recent command executions from CommandProvider with status indicators
class _RecentCommandsBanner extends StatelessWidget {
  final ThemeColors colors;

  const _RecentCommandsBanner({required this.colors});

  @override
  Widget build(BuildContext context) {
    final commandProvider = context.watch<CommandProvider>();
    final recentTasks = commandProvider.recentTasks;

    // Don't show if no tasks or only completed tasks older than 5 minutes
    if (recentTasks.isEmpty) {
      return const SizedBox.shrink();
    }

    // Filter to show only relevant tasks (running, completed in last 5 min, or failed)
    final relevantTasks = recentTasks.where((task) {
      if (task.status == CommandStatus.running) return true;
      if (task.status == CommandStatus.failed) return true;
      if (task.status == CommandStatus.completed) {
        return DateTime.now().difference(task.completedAt ?? task.createdAt).inMinutes < 5;
      }
      return false;
    }).toList();

    if (relevantTasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        border: Border.all(color: colors.border, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and clear button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history_outlined,
                    size: 14,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '最近指令',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => commandProvider.clearCompleted(),
                child: Text(
                  '清除',
                  style: TextStyle(
                    color: colors.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Command status cards
          ...relevantTasks.map((task) => _CommandStatusCard(
                task: task,
                colors: colors,
                onRetry: task.status == CommandStatus.failed
                    ? () => commandProvider.retryCommand(task.id)
                    : null,
                onRemove: () => commandProvider.removeTask(task.id),
              )),
        ],
      ),
    );
  }
}

/// Command Status Card Widget
/// Shows individual command status with progress and actions
class _CommandStatusCard extends StatelessWidget {
  final CommandTask task;
  final ThemeColors colors;
  final VoidCallback? onRetry;
  final VoidCallback? onRemove;

  const _CommandStatusCard({
    required this.task,
    required this.colors,
    this.onRetry,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border.all(
          color: _getBorderColor(task.status),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _getStatusColor(task.status).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(task.status),
              size: 12,
              color: _getStatusColor(task.status),
            ),
          ),

          const SizedBox(width: 10),

          // Command info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.command,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (task.currentStep != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    task.currentStep!,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Status badge and actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (task.status == CommandStatus.running) ...[
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getStatusColor(task.status),
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(task.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusText(task.status),
                    style: TextStyle(
                      color: _getStatusColor(task.status),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],

              if (task.status == CommandStatus.failed && onRetry != null) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onRetry,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colors.bgSecondary,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: colors.border, width: 1),
                    ),
                    child: Icon(
                      Icons.refresh_outlined,
                      size: 12,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],

              if (onRemove != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colors.bgSecondary,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: colors.border, width: 1),
                    ),
                    child: Icon(
                      Icons.close_outlined,
                      size: 12,
                      color: colors.textTertiary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(CommandStatus status) {
    switch (status) {
      case CommandStatus.pending:
        return colors.textSecondary;
      case CommandStatus.running:
        return colors.text;
      case CommandStatus.completed:
        return const Color(0xFF22C55E);
      case CommandStatus.failed:
        return const Color(0xFFEF4444);
    }
  }

  Color _getBorderColor(CommandStatus status) {
    switch (status) {
      case CommandStatus.pending:
        return colors.border;
      case CommandStatus.running:
        return colors.text.withOpacity(0.3);
      case CommandStatus.completed:
        return const Color(0xFF22C55E).withOpacity(0.3);
      case CommandStatus.failed:
        return const Color(0xFFEF4444).withOpacity(0.3);
    }
  }

  IconData _getStatusIcon(CommandStatus status) {
    switch (status) {
      case CommandStatus.pending:
        return Icons.schedule_outlined;
      case CommandStatus.running:
        return Icons.pending_outlined;
      case CommandStatus.completed:
        return Icons.check_circle_outline;
      case CommandStatus.failed:
        return Icons.error_outline;
    }
  }

  String _getStatusText(CommandStatus status) {
    switch (status) {
      case CommandStatus.pending:
        return '等待中';
      case CommandStatus.running:
        return '执行中';
      case CommandStatus.completed:
        return '完成';
      case CommandStatus.failed:
        return '失败';
    }
  }
}
