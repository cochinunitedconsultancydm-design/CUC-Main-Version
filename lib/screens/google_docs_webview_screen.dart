import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_windows/webview_windows.dart';
import '../theme.dart';

class GoogleDocsWebviewScreen extends StatefulWidget {
  final String url;
  final String title;

  const GoogleDocsWebviewScreen({
    super.key,
    required this.url,
    this.title = 'Google Docs Vault',
  });

  @override
  State<GoogleDocsWebviewScreen> createState() => _GoogleDocsWebviewScreenState();
}

class _GoogleDocsWebviewScreenState extends State<GoogleDocsWebviewScreen> {
  late final WebviewController _controller;
  bool _isLoading = true;
  bool _isWebviewInitialized = false;
  bool _hasError = false;

  static bool _environmentInitialized = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _launchForWeb();
    } else {
      initPlatformState();
    }
  }

  Future<void> _launchForWeb() async {
    final uri = Uri.parse(widget.url);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isWebviewInitialized = false;
      });
    }
    
    // Give the UI a frame to update before launching to prevent hanging if url_launcher throws
    await Future.delayed(const Duration(milliseconds: 100));
    
    try {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (e) {
      debugPrint('Could not launch $uri');
    }
  }

  Future<void> initPlatformState() async {
    _controller = WebviewController();
    try {
      if (!_environmentInitialized) {
        final appDir = await getApplicationSupportDirectory();
        final userDataPath = '${appDir.path}${Platform.pathSeparator}google_docs_webview_data';
        await Directory(userDataPath).create(recursive: true);
        await WebviewController.initializeEnvironment(
          userDataPath: userDataPath,
        );
        _environmentInitialized = true;
      }

      await _controller.initialize();

      _controller.loadingState.listen((state) {
        if (mounted) {
          setState(() {
            _isLoading = state == LoadingState.loading;
          });
        }
      });

      await _controller.setBackgroundColor(Colors.transparent);
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);

      if (!mounted) return;
      setState(() {
        _isWebviewInitialized = true;
      });

      await _controller.loadUrl(widget.url);
    } on PlatformException catch (e) {
      if (e.code == 'environment_already_initialized' || _environmentInitialized) {
        _environmentInitialized = true;
        try {
          if (!_controller.value.isInitialized) {
            await _controller.initialize();
          }

          _controller.loadingState.listen((state) {
            if (mounted) {
              setState(() {
                _isLoading = state == LoadingState.loading;
              });
            }
          });

          await _controller.setBackgroundColor(Colors.transparent);
          await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);

          if (!mounted) return;
          setState(() {
            _isWebviewInitialized = true;
          });

          await _controller.loadUrl(widget.url);
          return;
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.description_rounded, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                  ),
            ),
          ],
        ),
        actions: [
          if (_isWebviewInitialized && !kIsWeb)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryColor),
              onPressed: () {
                _controller.reload();
              },
            ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppTheme.primaryColor.withValues(alpha: 0.15),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            if (kIsWeb)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.open_in_new_rounded, size: 64, color: AppTheme.primaryColor),
                    const SizedBox(height: 24),
                    const Text('Document opened in a new tab', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('If you don\'t see the document, your browser might have blocked the popup.', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _launchForWeb,
                      icon: const Icon(Icons.launch_rounded),
                      label: const Text('Open Document manually'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            if (!kIsWeb && _isWebviewInitialized)
              Listener(
                onPointerSignal: (pointerSignal) {
                  if (pointerSignal is PointerScrollEvent) {
                    final String jsScript = '''
                      var deltaY = ${pointerSignal.scrollDelta.dy};
                      var deltaX = ${pointerSignal.scrollDelta.dx};
                      
                      // Google Docs specific scroll container
                      var kixEditor = document.querySelector('.kix-appview-editor');
                      if (kixEditor) {
                        kixEditor.scrollTop += deltaY;
                        kixEditor.scrollLeft += deltaX;
                      } else {
                        // Fallback for standard elements
                        var x = ${pointerSignal.localPosition.dx};
                        var y = ${pointerSignal.localPosition.dy};
                        var target = document.elementFromPoint(x, y) || document.body;
                        
                        var ev = new WheelEvent('wheel', {
                          deltaY: deltaY,
                          deltaX: deltaX,
                          clientX: x,
                          clientY: y,
                          bubbles: true,
                          cancelable: true,
                          view: window
                        });
                        target.dispatchEvent(ev);
                        window.scrollBy(deltaX, deltaY);
                      }
                    ''';
                    _controller.executeScript(jsScript);
                  }
                },
                child: Webview(
                  _controller,
                  permissionRequested: (url, permissionKind, isUserInitiated) async {
                    return WebviewPermissionDecision.allow;
                  },
                ),
              ),
            if (_isLoading && !_hasError)
              IgnorePointer(
                child: Container(
                  color: AppTheme.backgroundColor.withValues(alpha: 0.6),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  ),
                ),
              ),
            if (_hasError)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to initialize WebView2 Runtime.\nPlease ensure WebView2 is installed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red, fontFamily: 'Montserrat', fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _hasError = false;
                          _isLoading = true;
                        });
                        initPlatformState();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}

