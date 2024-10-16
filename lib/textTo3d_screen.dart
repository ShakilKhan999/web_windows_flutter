import 'package:flutter/material.dart';
import 'package:web_windows/assets_view-screen.dart';
import 'model_viewer_screen.dart';

class TextTo3d extends StatefulWidget {
  const TextTo3d({Key? key}) : super(key: key);

  @override
  _TextTo3dState createState() => _TextTo3dState();
}

class _TextTo3dState extends State<TextTo3d> {
  String prompt = "";
  TextEditingController promptController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Text to 3D Model'),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.folder),
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) => AssetView()),
        //       );
        //     },
        //   ),
        // ],
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
