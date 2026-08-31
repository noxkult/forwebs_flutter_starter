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
  });

  final List<StartupPopupItem> items;
  final double heightFactor;
  final Future<void> Function() onHideToday;

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
    return FractionallySizedBox(
      heightFactor: widget.heightFactor,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.items.length,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemBuilder: (_, index) =>
                      _PopupContent(item: widget.items[index]),
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
                      child: const Text('오늘 하루 안보기'),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('닫기'),
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
  const _PopupContent({required this.item});

  final StartupPopupItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (item.imageUrl != null)
              Image.network(item.imageUrl!, height: 100, fit: BoxFit.contain)
            else if (item.assetImage != null)
              Image.asset(item.assetImage!, height: 100, fit: BoxFit.contain),
            if (item.title != null) ...[
              const SizedBox(height: 8),
              Text(item.title!, style: Theme.of(context).textTheme.titleMedium),
            ],
            if (item.message != null) ...[
              const SizedBox(height: 4),
              Text(item.message!, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
