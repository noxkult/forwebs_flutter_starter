import 'package:flutter/widgets.dart';

/// Content displayed by [StartupPopup].
class StartupPopupItem {
  const StartupPopupItem({
    required this.id,
    this.title,
    this.message,
    this.imageUrl,
    this.assetImage,
    this.onTap,
  });

  final String id;
  final String? title;
  final String? message;
  final String? imageUrl;
  final String? assetImage;
  final VoidCallback? onTap;
}
