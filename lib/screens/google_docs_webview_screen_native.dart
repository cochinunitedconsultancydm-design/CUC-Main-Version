// Native (Windows) implementation for the Google Docs WebView
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_windows/webview_windows.dart';

bool _environmentInitialized = false;

Future<WebviewController> initializeWebview({
  required String url,
  required Function(bool) onLoadingStateChanged,
  required VoidCallback onInitialized,
}) async {
  final controller = WebviewController();

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

    await controller.initialize();

    controller.loadingState.listen((state) {
      onLoadingStateChanged(state == LoadingState.loading);
    });

    await controller.setBackgroundColor(Colors.transparent);
    await controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);

    onInitialized();

    await controller.loadUrl(url);
  } on PlatformException catch (e) {
    if (e.code == 'environment_already_initialized' || _environmentInitialized) {
      _environmentInitialized = true;
      try {
        if (!controller.value.isInitialized) {
          await controller.initialize();
        }

        controller.loadingState.listen((state) {
          onLoadingStateChanged(state == LoadingState.loading);
        });

        await controller.setBackgroundColor(Colors.transparent);
        await controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);

        onInitialized();

        await controller.loadUrl(url);
        return controller;
      } catch (_) {}
    }
    rethrow;
  }

  return controller;
}

void disposeWebview(dynamic controller) {
  if (controller is WebviewController) {
    controller.dispose();
  }
}

void reloadWebview(dynamic controller) {
  if (controller is WebviewController) {
    controller.reload();
  }
}

Widget buildWebview(BuildContext context, dynamic controller) {
  if (controller is! WebviewController) {
    return const SizedBox.shrink();
  }
  return Listener(
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
        controller.executeScript(jsScript);
      }
    },
    child: Webview(
      controller,
      permissionRequested: (url, permissionKind, isUserInitiated) async {
        return WebviewPermissionDecision.allow;
      },
    ),
  );
}
