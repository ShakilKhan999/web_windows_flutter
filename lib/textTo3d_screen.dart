import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TextTo3d extends StatefulWidget {
  const TextTo3d({super.key});

  @override
  _TextTo3dState createState() => _TextTo3dState();
}

const String API_KEY = 'msy_5wFEvF64qc9zCLYY9vbTnfP5QZgAhtAjQIS8';

class _TextTo3dState extends State<TextTo3d> {
  String prompt = "";
  TextEditingController promptController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text to 3D Model'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: promptController,
              onChanged: (value) => prompt = value,
              decoration: InputDecoration(
                hintText: 'Enter your prompt',
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModelViewer(prompt: prompt),
                  ),
                );
              },
              child: Text('Generate'),
            ),
          ],
        ),
      ),
    );
  }
}

class ModelViewer extends StatefulWidget {
  final String prompt;

  ModelViewer({required this.prompt});

  @override
  _ModelViewerState createState() => _ModelViewerState();
}

class _ModelViewerState extends State<ModelViewer> {
  Object? _model;
  bool _loading = true;
  String? _error;
  String? _filePath;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _generateAndLoadModel();
  }

  Future<void> _generateAndLoadModel() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Step 1: Make a single POST request
      print('Sending POST request to Meshy AI API');
      final postResponse = await http.post(
        Uri.parse('https://api.meshy.ai/v2/text-to-3d'),
        headers: {
          'Authorization': 'Bearer $API_KEY',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "mode": "preview",
          "prompt": widget.prompt,
          "art_style": "realistic",
          "negative_prompt": "low quality, low resolution, low poly, ugly"
        }),
      );

      if (postResponse.statusCode != 202) {
        throw Exception('Failed to generate model: ${postResponse.statusCode}');
      }

      final postResult = jsonDecode(postResponse.body);
      print('POST response: $postResult');
      final String modelId = postResult['result'];
      print('Model ID received: $modelId');

      // Step 2: Poll the GET API until progress is 100% and OBJ URL is available
      String? objUrl;
      while (true) {
        await Future.delayed(Duration(seconds: 3));

        print('Sending GET request to check progress');
        final getResponse = await http.get(
          Uri.parse('https://api.meshy.ai/v2/text-to-3d/$modelId'),
          headers: {
            'Authorization': 'Bearer $API_KEY',
          },
        );

        if (getResponse.statusCode != 200) {
          throw Exception('Failed to poll model: ${getResponse.statusCode}');
        }

        final getResult = jsonDecode(getResponse.body);
        print('GET response: $getResult');
        setState(() {
          _progress = getResult['progress'];
        });

        if (getResult['progress'] == 100) {
          print('Model generation complete');
          objUrl = getResult['model_urls']['obj'];
          if (objUrl != null) {
            print('OBJ URL: $objUrl');
            break;
          } else {
            throw Exception('OBJ URL not found in the response');
          }
        }
      }

      // Step 3: Download and save the OBJ file
      final response = await http.get(Uri.parse(objUrl!));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/model.obj');
        await file.writeAsBytes(response.bodyBytes);
        _filePath = file.path;
        print('File saved to: $_filePath');
        print('File size: ${await file.length()} bytes');
        if (await file.exists()) {
          // Try to read the first few lines of the file
          final contents = await file.readAsString();
          final firstLines = contents.split('\n').take(5).join('\n');
          print('First few lines of the file:\n$firstLines');
          setState(() {
            _model = Object(fileName: _filePath!, isAsset: false);
            _loading = false;
          });
        } else {
          throw Exception('File was not saved successfully');
        }
      } else {
        throw Exception(
            'Failed to download the file. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('3D Model Viewer'),
      ),
      body: Center(
        child: _loading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blueGrey[300]!),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Generating model... $_progress%',
                    style: TextStyle(color: Colors.blueGrey[300]),
                  ),
                ],
              )
            : _error != null
                ? Text('Error: $_error',
                    style: TextStyle(color: Colors.red[300]))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 500,
                        height: 500,
                        child: _model != null
                            ? Cube(
                                onSceneCreated: (Scene scene) {
                                  scene.world.add(_model!);
                                  scene.camera.zoom = 10;
                                  scene.light.position
                                      .setFrom(Vector3(0, 10, 10));
                                  scene.light
                                      .setColor(Colors.black, 0.8, 0.5, 0.3);
                                  scene.camera.target.setFrom(Vector3(0, 0, 0));
                                  // scene.camera.rotate(15, 20);
                                  scene.update();
                                },
                              )
                            : Center(child: Text('Model not loaded')),
                      ),
                      SizedBox(height: 20),
                      Text('File path: $_filePath',
                          style: TextStyle(color: Colors.blueGrey[300])),
                    ],
                  ),
      ),
    );
  }
}
