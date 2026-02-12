import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../theme/theme_provider.dart';

/// Minimalist Toast Notification Widget
/// Displays at the top of the screen with elegant fade-in/fade-out animation
class ToastWidget extends StatefulWidget {
  final String message;
  final ThemeColors colors;
  final VoidCallback? onDismiss;

  const ToastWidget({
    super.key,
    required this.message,
    required this.colors,
    this.onDismiss,
  });

  @override
  State<ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Fade animation (0 to 1)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Slide animation (from top)
    _slideAnimation = Tween<double>(begin: -20.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Scale animation (iOS-style subtle scale)
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Start animation
    _controller.forward();

    // Auto dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            ),
          );
        },
        child: _buildToastContent(),
      ),
    );
  }

  Widget _buildToastContent() {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: widget.colors.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.colors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 18,
              color: widget.colors.accent,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                widget.message,
                style: TextStyle(
                  color: widget.colors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Toast Overlay Manager
/// Use this to show toast notifications from anywhere in the app
class ToastOverlay {
  static OverlayEntry? _overlayEntry;

  /// Show a toast notification
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    // Remove existing overlay if any
    remove();

    final colors = context.read<ThemeProvider>().colors;

    _overlayEntry = OverlayEntry(
      builder: (context) => ToastWidget(
        message: message,
        colors: colors,
        onDismiss: remove,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Remove the current toast
  static void remove() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
