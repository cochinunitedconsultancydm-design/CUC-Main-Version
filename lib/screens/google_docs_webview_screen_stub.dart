// Stub implementation for web platform
// These functions are never actually called on web (guarded by kIsWeb checks),
// but Dart's type system requires them to exist for the conditional import.

import 'package:flutter/material.dart';

Future<dynamic> initializeWebview({
  required String url,
  required Function(bool) onLoadingStateChanged,
  required VoidCallback onInitialized,
}) async {
  // This should never be called on web
  throw UnsupportedError('Webview is not supported on web');
}

void disposeWebview(dynamic controller) {
  // No-op on web
}

void reloadWebview(dynamic controller) {
  // No-op on web
}

Widget buildWebview(BuildContext context, dynamic controller) {
  // This should never be called on web
  return const SizedBox.shrink();
}
