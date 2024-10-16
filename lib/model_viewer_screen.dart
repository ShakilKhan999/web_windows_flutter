// lib/screens/model_viewer_screen.dart
import 'package:flutter/material.dart';
import 'package:web_windows/services/model_services.dart';
import '../widgets/cube_viewer.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ModelViewer extends StatefulWidget {
  final String prompt;

  ModelViewer({required this.prompt});

  @override
  _ModelViewerState createState() => _ModelViewerState();
}

class _ModelViewerState extends State<ModelViewer> {
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
      _filePath = await ModelService.generateModel(
        widget.prompt,
            (progress) => setState(() => _progress = progress),
      );
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
      print('Error: $e');
    }
  }

  Future<void> _downloadModel() async {
    if (_filePath == null) return;

    try {
      Directory? directory;
      List<Future<Directory?>> directoryOptions = [
        getApplicationDocumentsDirectory(),
        getTemporaryDirectory(),
      ];

      if (Platform.isAndroid) {
        directoryOptions.insert(0, getExternalStorageDirectory());
      }

      for (var directoryFuture in directoryOptions) {
        directory = await directoryFuture;
        if (directory != null) break;
      }

      if (directory == null) {
        throw Exception('Could not access any storage directory');
      }

      String fileName = 'model_${DateTime.now().millisecondsSinceEpoch}.obj';
      File downloadFile = File('${directory.path}/$fileName');

      // Copy the generated model file to the new location
      await File(_filePath!).copy(downloadFile.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Model saved to ${downloadFile.path}'),
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      print('Error saving model: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save model: ${e.toString()}')),
      );
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
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Generating model... $_progress%'),
          ],
        )
            : _error != null
            ? Text('Error: $_error')
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: CubeViewer(filePath: _filePath!),
            ),
            ElevatedButton(
              onPressed: _downloadModel,
              child: const Text('Download Model'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}