import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import '../theme.dart';

// Conditionally import dart:io and webview_windows only on non-web platforms
import 'google_docs_webview_screen_stub.dart'
    if (dart.library.io) 'google_docs_webview_screen_native.dart' as native_impl;

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
  bool _isLoading = true;
  bool _isWebviewInitialized = false;
  bool _hasError = false;

  // Only used on native (Windows) platform
  dynamic _nativeController;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initNative();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _initNative() async {
    try {
      _nativeController = await native_impl.initializeWebview(
        url: widget.url,
        onLoadingStateChanged: (bool isLoading) {
          if (mounted) {
            setState(() {
              _isLoading = isLoading;
            });
          }
        },
        onInitialized: () {
          if (mounted) {
            setState(() {
              _isWebviewInitialized = true;
            });
          }
        },
      );
    } catch (e) {
      debugPrint('Error initializing webview: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _launchForWeb() async {
    final uri = Uri.parse(widget.url);
    try {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (e) {
      debugPrint('Could not launch $uri');
    }
  }

  @override
  void dispose() {
    if (!kIsWeb && _nativeController != null) {
      native_impl.disposeWebview(_nativeController);
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
                native_impl.reloadWebview(_nativeController);
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
                    const Text('Document is ready', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Click the button below to open the Google Doc securely.', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _launchForWeb,
                      icon: const Icon(Icons.launch_rounded),
                      label: const Text('Open Document'),
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
              native_impl.buildWebview(context, _nativeController),
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
                        _initNative();
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
