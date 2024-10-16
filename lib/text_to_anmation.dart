import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AnimationGenerateScreen extends StatefulWidget {
  const AnimationGenerateScreen({Key? key}) : super(key: key);

  @override
  _AnimationGenerateScreenState createState() => _AnimationGenerateScreenState();
}

class _AnimationGenerateScreenState extends State<AnimationGenerateScreen> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _durationController = TextEditingController(text: "5.0");
  final ApiService _apiService = ApiService();
  List<Map<String, String>> files = [];
  bool isGenerating = false;
  bool showAnimationPlayer = false;
  String? glbFileUrl;
  int _progress = 0;
  String? _authError;
  bool _isAuthenticated = false;
  String _clientId = 'wPiGZ7C2GRMowihQ854Lmm';
  String _clientSecret = 'ciByB6D98HXR1T8uVbFiJb';
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _promptController.addListener(() {
      setState(() {});
    });
    _authenticateSayMotion();
    _initWebView();
    _loadStoredFiles();
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://bvh-player.web.app/BVH_player.html'));
  }

  Future<void> _loadStoredFiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedFiles = prefs.getString('generatedFiles');
    if (storedFiles != null) {
      setState(() {
        files = (jsonDecode(storedFiles) as List)
            .map((item) => Map<String, String>.from(item))
            .toList();
        showAnimationPlayer = true;
      });
    }
  }

  Future<void> _saveFiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('generatedFiles', jsonEncode(files));
  }


  Future<void> _authenticateSayMotion() async {
    final result = await _apiService.authenticate(_clientId, _clientSecret);

    setState(() {
      if (result['success'] == true) {
        _isAuthenticated = true;
        _authError = null;
      } else {
        _isAuthenticated = false;
        _authError = result['error'];
        if (result.containsKey('body')) {
          _authError = '$_authError\nResponse body: ${result['body']}';
        }
      }
    });

    if (!_isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication failed. Please check your credentials.'),
          action: SnackBarAction(
            label: 'Login',
            onPressed: _showLoginDialog,
          ),
        ),
      );
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login to SayMotion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Client ID'),
                controller: TextEditingController(text: _clientId),
                onChanged: (value) => _clientId = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Client Secret'),
                controller: TextEditingController(text: _clientSecret),
                obscureText: true,
                onChanged: (value) => _clientSecret = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Login'),
              onPressed: () {
                Navigator.of(context).pop();
                _authenticateSayMotion();
              },
            ),
          ],
        );
      },
    );
  }


  Future<void> generateAnimation() async {
    if (_promptController.text.isEmpty || !_isAuthenticated) return;

    setState(() {
      isGenerating = true;
      showAnimationPlayer = false;
      _progress = 0;
    });

    try {
      final jobData = await _apiService.startTextToMotionJob(
        _promptController.text,
        double.parse(_durationController.text),
      );

      if (jobData['error'] == true) {
        throw Exception(jobData['message']);
      }

      final String rid = jobData['rid'];

      while (true) {
        await Future.delayed(const Duration(seconds: 3));
        final statusData = await _apiService.getJobStatus(rid);
        final status = statusData['status'][0]['status'];

        if (status == 'SUCCESS') {
          final downloadData = await _apiService.downloadGlbFile(rid);

          if (downloadData['error'] == true) {
            throw Exception(downloadData['message']);
          }

          final List<Map<String, String>> newFiles = extractFileInfo(downloadData);

          setState(() {
            files = newFiles;
            isGenerating = false;
            showAnimationPlayer = true;
          });

          await _saveFiles();  // Save the new files to SharedPreferences
          break;
        } else if (status == 'FAILURE') {
          throw Exception('Job failed');
        } else {
          setState(() {
            _progress = (statusData['status'][0]['details']['step'] / statusData['status'][0]['details']['total'] * 100).round();
          });
        }
      }
    } catch (e) {
      setState(() {
        isGenerating = false;
      });
      _showErrorDialog('Failed to generate animation', e.toString());
    }
  }
  List<Map<String, String>> extractFileInfo(Map<String, dynamic> downloadData) {
    List<Map<String, String>> files = [];

    if (downloadData['links'] != null && downloadData['links'] is List) {
      final links = downloadData['links'][0];
      if (links['urls'] != null && links['urls'] is List) {
        final urls = links['urls'] as List<dynamic>;
        for (var url in urls) {
          final name = url['name'];
          final fileList = url['files'] as List<dynamic>;
          for (var file in fileList) {
            file.forEach((key, value) {
              files.add({
                'name': '$name.$key',
                'url': value,
              });
            });
          }
        }
      }
    }

    return files;
  }

  String? extractGlbFileUrl(String jsonData) {
    final data = json.decode(jsonData);
    final urls = data[0]['urls'] as List<dynamic>;
    final modelFiles = urls.firstWhere(
          (url) => url['name'] == 'pWMyN6Kn45PtHhNJFC4xN5_v1',
      orElse: () => null,
    );

    if (modelFiles != null) {
      final files = modelFiles['files'] as List<dynamic>;
      final glbFile = files.firstWhere(
            (file) => file['glb'] != null,
        orElse: () => null,
      );

      if (glbFile != null) {
        return glbFile['glb'] as String;
      }
    }

    return null;
  }

  void _loadGlbFile(String url) {
    final encodedUrl = Uri.encodeComponent(url);
    final playerUrl = 'https://bvh-player.web.app/BVH_player.html?glb=$encodedUrl';
    _webViewController.loadRequest(Uri.parse(playerUrl));
  }


  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade900, Colors.black],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_authError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Authentication Error: $_authError',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                TextField(
                  controller: _promptController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Describe your animation...',
                    hintStyle: const TextStyle(color: Colors.white60),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.animation, color: Colors.white60),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _durationController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Duration in seconds',
                    hintStyle: const TextStyle(color: Colors.white60),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.timer, color: Colors.white60),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: (_promptController.text.isNotEmpty && !isGenerating && _isAuthenticated)
                      ? generateAnimation
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Generate'),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GlassmorphicContainer(
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 30,
                    blur: 20,
                    alignment: Alignment.center,
                    border: 2,
                    linearGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    borderGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.5),
                        Colors.white.withOpacity(0.5),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: isGenerating
                          ? _buildLoadingUI()
                          : showAnimationPlayer
                          ? _buildAnimationPlayerUI()
                          : _buildInitialUI(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildInitialUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.animation,
          size: 80,
          color: Colors.white,
        ),
        SizedBox(height: 20),
        Text(
          'Generate your own animation with AI',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        Text(
          'Enter a description, then click Generate.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
        const SizedBox(height: 20),
        const Text(
          'Generating your animation...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 20),
        LinearProgressIndicator(
          value: _progress / 100,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
          backgroundColor: Colors.white.withOpacity(0.3),
        ),
        const SizedBox(height: 10),
        Text(
          '$_progress%',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimationPlayerUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Your Animation Files',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: files.isEmpty
              ? Center(child: Text('No files available', style: TextStyle(color: Colors.white)))
              : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: files.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () async {
                  final url = Uri.parse(files[index]['url']!);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not launch ${files[index]['name']}')),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.file_present, color: Colors.white, size: 32),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          files[index]['name']!,
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}