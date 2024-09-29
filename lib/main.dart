import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:web_windows/edite_view.dart';
import 'package:web_windows/live_editor.dart';
import 'package:web_windows/text_to_music.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'assets_view.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await hotKeyManager.unregisterAll();
  WebViewPlatform.instance = WebKitWebViewPlatform();
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
        home: ExampleBrowser(),
      ),
    );
  }
}

class ExampleBrowser extends StatefulWidget {
  @override
  State<ExampleBrowser> createState() => _ExampleBrowser();
}

class _ExampleBrowser extends State<ExampleBrowser> with WindowListener {
  late final WebViewController _controller;
  bool _showAssets = false;
  bool _showEditPage = false;
  bool _showLiveEditPage = false;
  bool _showMusicPage = false;
  bool _showSpotlight = false;
  Offset _spotlightPosition = Offset(20, 20);

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://text-to-3d--new1-7ebce.us-central1.hosted.app/'));
    _initSpotlight();
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

  @override
  void dispose() {
    windowManager.removeListener(this);
    hotKeyManager.unregisterAll();
    super.dispose();
  }

  Widget compositeView() {
    if (_showAssets) {
      return AssetsView();
    } else if (_showEditPage) {
      return EditPage();
    } else if (_showLiveEditPage) {
      return LiveEditor();
    } else if (_showMusicPage) {
      return MusicGenerateScreen();
    } else {
      return WebViewWidget(controller: _controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.minimize),
            onPressed: () async {
              await windowManager.minimize();
            },
          ),
        ],
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
                'Text to 3D Converter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                setState(() {
                  _showAssets = false;
                  _showEditPage = false;
                  _showMusicPage = false;
                  _showLiveEditPage = false;
                });
                _controller.loadRequest(Uri.parse('https://text-to-3d--new1-7ebce.us-central1.hosted.app/'));
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
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
              onTap: () {
                setState(() {
                  _showAssets = false;
                  _showEditPage = true;
                  _showMusicPage = false;
                  _showLiveEditPage = false;
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
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          compositeView(),
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