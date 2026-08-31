import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/startup_popup_item.dart';

/// A reusable startup bottom popup with optional carousel content.
class StartupPopup {
  const StartupPopup._();

  static Future<void> show(
    BuildContext context, {
    required List<StartupPopupItem> items,
    String storageKey = 'startup_popup_hidden_until',
    double heightFactor = .38,
    Color? bottomBackgroundColor,
    String hideTodayText = '오늘 하루 안보기',
    String closeText = '닫기',
  }) async {
    if (items.isEmpty || !context.mounted) return;
    final preferences = await SharedPreferences.getInstance();
    final hiddenUntil = preferences.getString(storageKey);
    if (hiddenUntil == _todayKey()) return;
    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StartupPopupSheet(
        items: items,
        heightFactor: heightFactor,
        bottomBackgroundColor: bottomBackgroundColor,
        hideTodayText: hideTodayText,
        closeText: closeText,
        onHideToday: () async {
          await preferences.setString(storageKey, _todayKey());
        },
      ),
    );
  }

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}

class _StartupPopupSheet extends StatefulWidget {
  const _StartupPopupSheet({
    required this.items,
    required this.heightFactor,
    required this.onHideToday,
    this.bottomBackgroundColor,
    required this.hideTodayText,
    required this.closeText,
  });

  final List<StartupPopupItem> items;
  final double heightFactor;
  final Future<void> Function() onHideToday;
  final Color? bottomBackgroundColor;
  final String hideTodayText;
  final String closeText;

  @override
  State<_StartupPopupSheet> createState() => _StartupPopupSheetState();
}

class _StartupPopupSheetState extends State<_StartupPopupSheet> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _hideToday() async {
    await widget.onHideToday();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isSingleImagePopup =
        widget.items.length == 1 &&
        widget.items.first.title == null &&
        widget.items.first.message == null &&
        (widget.items.first.imageUrl != null ||
            widget.items.first.assetImage != null);
    final maxSheetHeight = MediaQuery.sizeOf(context).height * .9;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      child: Material(
        color:
            widget.bottomBackgroundColor ??
            Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              if (isSingleImagePopup)
                _PopupContent(
                  item: widget.items.first,
                  maxImageHeight: maxSheetHeight,
                )
              else
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => PageView.builder(
                      controller: _pageController,
                      itemCount: widget.items.length,
                      onPageChanged: (page) =>
                          setState(() => _currentPage = page),
                      itemBuilder: (_, index) => _PopupContent(
                        item: widget.items[index],
                        maxImageHeight: constraints.maxHeight,
                      ),
                    ),
                  ),
                ),
              if (widget.items.length > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.items.length,
                    (index) => Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentPage
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: _hideToday,
                      child: Text(widget.hideTodayText),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(widget.closeText),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopupContent extends StatelessWidget {
  const _PopupContent({required this.item, required this.maxImageHeight});

  final StartupPopupItem item;
  final double maxImageHeight;

  @override
  Widget build(BuildContext context) {
    final hasImage = item.imageUrl != null || item.assetImage != null;
    return Material(
      color: item.backgroundColor ?? Colors.transparent,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasImage)
              _PopupImage(
                item: item,
                maxHeight: maxImageHeight,
                onPressed: _actionPressed(context),
              ),
            if (item.title != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  item.title!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
            if (item.message != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(item.message!, textAlign: TextAlign.center),
              ),
            ],
            if (!hasImage && item.actionText != null && item.onTap != null) ...[
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () {
                  item.onTap!();
                  if (context.mounted &&
                      (ModalRoute.of(context)?.isCurrent ?? false)) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(item.actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  VoidCallback? _actionPressed(BuildContext context) {
    if (item.actionText == null || item.onTap == null) return null;
    return () {
      item.onTap!();
      if (context.mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
        Navigator.of(context).pop();
      }
    };
  }
}

class _PopupImage extends StatelessWidget {
  const _PopupImage({
    required this.item,
    required this.maxHeight,
    required this.onPressed,
  });

  final StartupPopupItem item;
  final double maxHeight;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final image = item.imageUrl != null
        ? Image.network(
            item.imageUrl!,
            width: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          )
        : Image.asset(
            item.assetImage!,
            width: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          );

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          image,
          if (item.actionText != null)
            Positioned(
              bottom: 12,
              left: 16,
              right: 16,
              child: Center(
                child: FilledButton(
                  onPressed: onPressed,
                  child: Text(item.actionText!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
