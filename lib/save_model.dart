import 'package:flutter/material.dart';
import '../widgets/cube_viewer.dart';

class SavedModelViewer extends StatefulWidget {
  final List<String> savedModels;
  final int initialIndex;

  SavedModelViewer({required this.savedModels, required this.initialIndex});

  @override
  _SavedModelViewerState createState() => _SavedModelViewerState();
}

class _SavedModelViewerState extends State<SavedModelViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('3D Model Viewer'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.savedModels.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return CubeViewer(filePath: widget.savedModels[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
