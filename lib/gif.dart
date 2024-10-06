import 'package:flutter/material.dart';
import 'package:gif/gif.dart';

class GifDragDropScreen extends StatefulWidget {
  @override
  _GifDragDropScreenState createState() => _GifDragDropScreenState();
}

class _GifDragDropScreenState extends State<GifDragDropScreen>
    with SingleTickerProviderStateMixin {
  GifController? _selectedGifController;
  String? _selectedGif;

  final List<String> gifList = [
    'assets/gif/gif.gif',
    'assets/gif/1.gif',
    'assets/gif/2.gif',
    'assets/gif/3.gif',
  ];

  @override
  void dispose() {
    _selectedGifController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gif Drag & Drop'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _selectedGif != null
                  ? Gif(
                      image: AssetImage(_selectedGif!),
                      controller: _selectedGifController,
                      onFetchCompleted: () {
                        if (_selectedGifController?.duration != null) {
                          // Convert the GIF duration into the total frame count and repeat the GIF
                          final totalFrames = _selectedGifController!
                              .duration!.inMilliseconds
                              .toDouble();
                          _selectedGifController?.repeat(
                              min: 0, max: totalFrames);
                        }
                      },
                    )
                  : Container(
                      color: Colors.grey[200],
                      width: 300,
                      height: 300,
                      child: Center(
                        child: Text('Drag GIF here'),
                      ),
                    ),
            ),
          ),

          // List of GIFs at the bottom (static, no animation)
          Container(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: gifList.length,
              itemBuilder: (context, index) {
                return Draggable<String>(
                  data: gifList[index],
                  feedback: Material(
                    child: Image.asset(
                      gifList[index],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.5,
                    child: Image.asset(
                      gifList[index],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Image.asset(
                    gifList[index],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // DragTarget at the center to detect dropped GIFs
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: DragTarget<String>(
        onAccept: (gifPath) {
          setState(() {
            _selectedGif = gifPath;
            _selectedGifController = GifController(vsync: this);
          });
        },
        builder: (context, candidateData, rejectedData) {
          return SizedBox();
        },
      ),
    );
  }
}
