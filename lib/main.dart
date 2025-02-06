import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_windows/assets_view-screen.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

// Platform-specific imports
import 'package:webview_flutter/webview_flutter.dart'
    if (dart.library.html) 'package:webview_flutter_web/webview_flutter_web.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_windows/webview_windows.dart' as webview_windows;

// Your other imports here
import '../edite_view.dart';
import '../live_editor.dart';
import '../splash_screen.dart';
import '../textTo3d_screen.dart';
import '../text_to_anmation.dart';
import '../text_to_music.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await hotKeyManager.unregisterAll();

  if (Platform.isMacOS) {
    WebViewPlatform.instance = WebKitWebViewPlatform();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: ThemeData.dark(),
        home: const SplashScreen(),
      ),
    );
  }
}

class ExampleBrowser extends StatefulWidget {
  @override
  State<ExampleBrowser> createState() => _ExampleBrowser();
}

class _ExampleBrowser extends State<ExampleBrowser> with WindowListener {
  late final dynamic _controller;
  late final dynamic _controllerViewer;
  bool _isWebViewReady = false;
  bool _showAssets = false;
  bool _showEditPage = false;
  bool _showLiveEditPage = false;
  bool _showMusicPage = false;
  bool _showSpotlight = false;
  bool _showTextAnimation = false;
  bool _showViewer = false;
  Offset _spotlightPosition = Offset(20, 20);

  @override
  void initState() {
    super.initState();
    _initWebView();
    _initSpotlight();
  }

  Future<void> _initWebView() async {
    if (Platform.isWindows) {
      _controller = webview_windows.WebviewController();
      _controllerViewer = webview_windows.WebviewController();
      await _initWindowsWebView();
    } else if (Platform.isMacOS) {
      _controller = WebViewController();
      _controllerViewer = WebViewController();
      await _initMacOSWebView();
    }

    setState(() {
      _isWebViewReady = true;
    });
  }

  Future<void> _initWindowsWebView() async {
    try {
      await _controller.initialize();
      await _controller.setBackgroundColor(Colors.transparent);
      await _controller
          .setPopupWindowPolicy(webview_windows.WebviewPopupWindowPolicy.deny);
      await _controller
          .loadUrl('https://text-to-3d--new1-7ebce.us-central1.hosted.app/');

      await _controllerViewer.initialize();
      await _controllerViewer.setBackgroundColor(Colors.transparent);
      await _controllerViewer
          .setPopupWindowPolicy(webview_windows.WebviewPopupWindowPolicy.deny);
      await _controllerViewer
          .loadUrl('https://bvh-player.web.app/BVH_player.html');
    } catch (e) {
      print('Error initializing Windows WebView: $e');
    }
  }

  Future<void> _initMacOSWebView() async {
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // Handle page finished loading
          },
        ),
      )
      ..loadRequest(
          Uri.parse('https://text-to-3d--new1-7ebce.us-central1.hosted.app/'));

    _controllerViewer
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterFilePicker',
        onMessageReceived: (JavaScriptMessage message) async {
          await _handleFilePicker();
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            _injectFileInputInterceptor();
          },
        ),
      )
      ..loadRequest(Uri.parse('https://bvh-player.web.app/BVH_player.html'));
  }

  Future<void> _initSpotlight() async {
    await windowManager.setSize(Size(800, 600));
    await windowManager.setMinimumSize(Size(400, 300));
    await _registerHotKey();
  }

  Future<void> _registerHotKey() async {
    await hotKeyManager.register(
      HotKey(
        KeyCode.enter,
        modifiers: [KeyModifier.meta],
        scope: HotKeyScope.system,
      ),
      keyDownHandler: (hotKey) {
        setState(() {
          _showSpotlight = !_showSpotlight;
        });
      },
    );
  }

  Future<void> _injectFileInputInterceptor() async {
    if (Platform.isWindows) {
      await _controllerViewer.executeScript('''
        (function() {
          const originalClick = HTMLInputElement.prototype.click;
          HTMLInputElement.prototype.click = function() {
            if (this.type === 'file') {
              window.chrome.webview.postMessage('open');
              return;
            }
            originalClick.call(this);
          };
        })();
      ''');
    } else if (Platform.isMacOS) {
      await _controllerViewer.runJavaScript('''
        (function() {
          const originalClick = HTMLInputElement.prototype.click;
          HTMLInputElement.prototype.click = function() {
            if (this.type === 'file') {
              FlutterFilePicker.postMessage('open');
              return;
            }
            originalClick.call(this);
          };
        })();
      ''');
    }
    log("File input interceptor injected");
  }

  Future<void> _handleFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bvh'],
    );
    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;
      List<int> fileBytes = await file.readAsBytes();
      String base64File = base64Encode(fileBytes);

      log("Sending file to WebView: $fileName");
      try {
        String script = '''
          var fileInput = document.querySelector('input[type="file"]');
          if (fileInput) {
            var file = new File([Uint8Array.from(atob('$base64File').split('').map(c => c.charCodeAt(0)))], '$fileName');
            var dataTransfer = new DataTransfer();
            dataTransfer.items.add(file);
            fileInput.files = dataTransfer.files;
            var event = new Event('change', { bubbles: true });
            fileInput.dispatchEvent(event);
          } else {
            console.error('File input not found');
          }
        ''';

        if (Platform.isWindows) {
          await _controllerViewer.executeScript(script);
        } else if (Platform.isMacOS) {
          await _controllerViewer.runJavaScript(script);
        }
        log("File sent to WebView");
      } catch (e) {
        log("Error sending file to WebView: $e");
      }
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    hotKeyManager.unregisterAll();
    if (Platform.isWindows) {
      _controller.dispose();
      _controllerViewer.dispose();
    }
    super.dispose();
  }

  Widget compositeView() {
    if (_showAssets) {
      return AssetView();
    } else if (_showEditPage) {
      return EditPage();
    } else if (_showLiveEditPage) {
      return LiveEditor();
    } else if (_showMusicPage) {
      return MusicGenerateScreen();
    } else if (_showTextAnimation) {
      return AnimationGenerateScreen();
    } else if (_showViewer) {
      return _buildWebViewWithButton();
    } else {
      return TextTo3d();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Playa3ull'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.grey[850],
              ),
              child: Text(
                'Playa3ull',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Text to 3d model'),
              onTap: () {
                setState(() {
                  _showAssets = false;
                  _showEditPage = false;
                  _showMusicPage = false;
                  _showLiveEditPage = false;
                  _showTextAnimation = false;
                  _showViewer = false;
                });
                if (Platform.isWindows) {
                  _controller.loadUrl(
                      'https://text-to-3d--new1-7ebce.us-central1.hosted.app/');
                } else if (Platform.isMacOS) {
                  _controller.loadRequest(Uri.parse(
                      'https://text-to-3d--new1-7ebce.us-central1.hosted.app/'));
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text('Assets'),
              onTap: () {
                setState(() {
                  _showAssets = true;
                  _showEditPage = false;
                  _showMusicPage = false;
                  _showLiveEditPage = false;
                  _showTextAnimation = false;
                  _showViewer = false;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('IDE'),
              onTap: () {
                setState(() {
                  _showAssets = false;
                  _showEditPage = true;
                  _showMusicPage = false;
                  _showLiveEditPage = false;
                  _showTextAnimation = false;
                  _showViewer = false;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.code),
              title: Text('Live Editor'),
              onTap: () {
                setState(() {
                  _showAssets = false;
                  _showEditPage = false;
                  _showMusicPage = false;
                  _showLiveEditPage = true;
                  _showTextAnimation = false;
                  _showViewer = false;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.music_note),
              title: Text('Text To Music'),
              onTap: () {
                setState(() {
                  _showAssets = false;
                  _showEditPage = false;
                  _showMusicPage = true;
                  _showLiveEditPage = false;
                  _showTextAnimation = false;
                  _showViewer = false;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.animation),
              title: Text('Text To Animation'),
              onTap: () {
                setState(() {
                  _showAssets = false;
                  _showEditPage = false;
                  _showMusicPage = false;
                  _showLiveEditPage = false;
                  _showSpotlight = false;
                  _showViewer = false;
                  _showTextAnimation = true;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.animation),
              title: const Text('Animation viewer'),
              onTap: () {
                setState(() {
                  _showAssets = false;
                  _showEditPage = false;
                  _showMusicPage = false;
                  _showLiveEditPage = false;
                  _showSpotlight = false;
                  _showTextAnimation = false;
                  _showViewer = true;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          if (_isWebViewReady)
            compositeView()
          else
            Center(child: CircularProgressIndicator()),
          if (_showSpotlight)
            Positioned(
              left: _spotlightPosition.dx,
              top: _spotlightPosition.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _spotlightPosition += details.delta;
                  });
                },
                child: SpotlightWidget(
                  onClose: () {
                    setState(() {
                      _showSpotlight = false;
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWebViewWithButton() {
    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Platform.isWindows
              ? webview_windows.Webview(_controllerViewer)
              : WebViewWidget(controller: _controllerViewer),
        ),
        Positioned(
          left: 10,
          bottom: 5,
          child: GestureDetector(
            onTap: _handleFilePicker,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Padding(
                padding: const EdgeInsets.all(7.0),
                child: Text(
                  'Choose File',
                  style: TextStyle(
                    color: Color(0xFFA2A2A2),
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SpotlightWidget extends StatefulWidget {
  final VoidCallback onClose;

  const SpotlightWidget({Key? key, required this.onClose}) : super(key: key);

  @override
  _SpotlightWidgetState createState() => _SpotlightWidgetState();
}

class _SpotlightWidgetState extends State<SpotlightWidget> {
  bool _isProEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      height: 60,
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ask anything...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          _buildButton(Icons.format_align_left, 'Focus'),
          _buildButton(Icons.add, 'Attach'),
          SizedBox(width: 10),
          Switch(
            value: _isProEnabled,
            onChanged: (value) {
              setState(() {
                _isProEnabled = value;
              });
            },
            activeColor: Colors.green,
          ),
          SizedBox(width: 10),
          Text(
            'Pro',
            style: TextStyle(color: _isProEnabled ? Colors.green : Colors.grey),
          ),
          SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildButton(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, color: Colors.grey),
        onPressed: () {},
      ),
    );
  }
}
