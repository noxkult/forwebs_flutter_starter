import 'package:flutter/material.dart';

/// The visual type of a short-lived application message.
enum SnackType {
  success,
  warning,
  error,
  transparent,

  /// Kept for compatibility with the original API.
  @Deprecated('Use transparent instead')
  trance,
}

/// Common UI helpers shared across applications.
abstract final class UIHelper {
  /// Shows a short-lived message using the nearest [ScaffoldMessenger].
  static void showSnackBar(
    BuildContext context,
    String message, {
    SnackType type = SnackType.error,
    Duration duration = const Duration(seconds: 2),
  }) {
    final (backgroundColor, icon) = switch (type) {
      SnackType.success => (Colors.green, Icons.check_circle),
      SnackType.warning => (Colors.orange, Icons.warning_amber_rounded),
      SnackType.error => (Colors.red, Icons.error_outline),
      SnackType.transparent ||
      SnackType.trance => (Colors.transparent, Icons.pending_rounded),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: backgroundColor,
          duration: duration,
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
