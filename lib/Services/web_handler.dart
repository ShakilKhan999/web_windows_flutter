// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:universal_platform/universal_platform.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
//
// // Conditional import for web
// import 'webview_web.dart' if (dart.library.html) 'webview_web_real.dart';
//
// class WebViewHandler {
//   late final WebViewInterface _webViewInterface;
//   bool _isWebViewReady = false;
//
//   bool get isReady => _isWebViewReady;
//
//   final String mainUrl = 'https://text-to-3d--new1-7ebce.us-central1.hosted.app/';
//   final String viewerUrl = 'https://bvh-player.web.app/BVH_player.html';
//
//   Future<void> initialize() async {
//     _webViewInterface = createWebView();
//     await _webViewInterface.initialize(mainUrl, viewerUrl);
//     _isWebViewReady = true;
//   }
//
//   Widget buildViewer(BuildContext context) {
//     return _webViewInterface.buildViewer(context);
//   }
//
//   Future<void> handleFilePicker() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['bvh'],
//     );
//
//     if (result != null) {
//       if (UniversalPlatform.isWeb) {
//         final bytes = result.files.single.bytes;
//         if (bytes != null) {
//           final base64File = base64Encode(bytes);
//           _webViewInterface.injectFile(base64File, result.files.single.name);
//         }
//       } else {
//         final file = File(result.files.single.path!);
//         final bytes = await file.readAsBytes();
//         final base64File = base64Encode(bytes);
//         _webViewInterface.injectFile(base64File, result.files.single.name);
//       }
//     }
//   }
//
//   void loadMainUrl() {
//     _webViewInterface.loadMainUrl(mainUrl);
//   }
//
//   void dispose() {
//     _webViewInterface.dispose();
//   }
// }