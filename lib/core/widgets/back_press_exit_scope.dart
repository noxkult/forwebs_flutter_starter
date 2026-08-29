import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helpers/ui_helper.dart';

/// Prevents accidental app exits by requiring two back presses.
///
/// Place this around the app's root page, usually the [MaterialApp] `home`:
///
/// ```dart
/// home: const BackPressExitScope(child: HomeScreen()),
/// ```
class BackPressExitScope extends StatefulWidget {
  const BackPressExitScope({
    super.key,
    required this.child,
    this.message = '한번 더 누르면 종료됩니다.',
    this.interval = const Duration(seconds: 2),
  });

  final Widget child;
  final String message;
  final Duration interval;

  @override
  State<BackPressExitScope> createState() => _BackPressExitScopeState();
}

class _BackPressExitScopeState extends State<BackPressExitScope> {
  DateTime? _lastBackPressedAt;

  void _handleBack() {
    final now = DateTime.now();
    final lastPressedAt = _lastBackPressedAt;

    if (lastPressedAt != null &&
        now.difference(lastPressedAt) <= widget.interval) {
      SystemNavigator.pop();
      return;
    }

    _lastBackPressedAt = now;
    UIHelper.showSnackBar(context, widget.message, type: SnackType.warning);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: widget.child,
    );
  }
}
