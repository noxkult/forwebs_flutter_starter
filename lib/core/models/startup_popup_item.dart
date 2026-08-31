import 'package:flutter/material.dart';

/// Content displayed by [StartupPopup].
class StartupPopupItem {
  const StartupPopupItem({
    required this.id,
    this.title,
    this.message,
    this.imageUrl,
    this.assetImage,
    this.actionText,
    this.actionType,
    this.actionValue,
    this.backgroundColor,
    this.onTap,
  });

  final String id;
  final String? title;
  final String? message;
  final String? imageUrl;
  final String? assetImage;
  final String? actionText;
  final String? actionType;
  final String? actionValue;
  final Color? backgroundColor;
  final VoidCallback? onTap;
}
