import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Displays [url] in a full-screen web view.
///
/// Push this screen from any app with:
///
/// ```dart
/// Navigator.of(context).push(
///   MaterialPageRoute(
///     builder: (_) => const WebViewScreen(url: 'https://example.com'),
///   ),
/// );
/// ```
class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key, required this.url});

  final String url;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadPage();
    });
  }

  Future<void> _loadPage() async {
    final uri = Uri.tryParse(widget.url);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      _showError('올바른 웹 주소가 아닙니다.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Theme.of(context).scaffoldBackgroundColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? true) {
              _showError(error.description);
            }
          },
          onNavigationRequest: (request) {
            final navigationUri = Uri.tryParse(request.url);
            return navigationUri?.scheme == 'http' ||
                    navigationUri?.scheme == 'https'
                ? NavigationDecision.navigate
                : NavigationDecision.prevent;
          },
        ),
      );

    if (!mounted) return;
    setState(() => _controller = controller);
    try {
      await controller.loadRequest(uri);
    } on PlatformException catch (error) {
      _showError(error.message ?? '페이지를 불러올 수 없습니다.');
    } catch (_) {
      _showError('페이지를 불러올 수 없습니다.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _errorMessage = message.isEmpty ? '페이지를 불러올 수 없습니다.' : message;
    });
  }

  Future<bool> _handleBack() async {
    final controller = _controller;
    if (controller != null && await controller.canGoBack()) {
      await controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && await _handleBack() && context.mounted) {
          Navigator.of(context).pop(result);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              if (_errorMessage == null && _controller != null)
                WebViewWidget(controller: _controller!),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
              if (_errorMessage != null)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 12),
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _loadPage,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: SafeArea(
                  child: Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(28),
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.78),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.close, size: 18, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                '닫기',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
