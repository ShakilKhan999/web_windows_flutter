import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'dart:async';

class LiveEditor extends StatefulWidget {
  const LiveEditor({super.key});

  @override
  State<LiveEditor> createState() => _LiveEditorState();
}

class _LiveEditorState extends State<LiveEditor> {
  List<Map<String, dynamic>> chatMessages = [
    {"text": "What can I help you with?", "isUser": false},
  ];

  List<String> gifList = [
    "assets/gif/doomgif.gif",
    "assets/gif/doom2.gif",
    "assets/gif/doom3.gif"
  ];

  List<String> aiReplies = [
    "Generating..",
  ];

  int currentGifIndex = 0;
  bool started = false;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isBackgroundLoaded = false;
  bool _isChangingBackground = false;

  @override
  void initState() {
    super.initState();
    _loadInitialBackground();
  }

  void _loadInitialBackground() {
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isBackgroundLoaded = true;
      });
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        started = true;
        chatMessages.add({"text": _controller.text, "isUser": true});
        _controller.clear();
        _isChangingBackground = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          currentGifIndex = (currentGifIndex + 1) % gifList.length;
          String aiResponse = aiReplies[0];
          chatMessages.add({"text": aiResponse, "isUser": false});
          _isChangingBackground = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      });
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            if (_isBackgroundLoaded && started == true)
              Image.asset(
                gifList[currentGifIndex],
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              )
            else
              Center(
                child: CircularProgressIndicator(),
              ),
            if (_isChangingBackground)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: GlassmorphicContainer(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.height * 0.5,
                  borderRadius: 20,
                  blur: 20,
                  alignment: Alignment.bottomCenter,
                  border: 2,
                  linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                    ],
                    stops: [0.1, 1],
                  ),
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0.5),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: chatMessages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: chatMessages[index]["isUser"]
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: chatMessages[index]["isUser"]
                                        ? Colors.greenAccent.withOpacity(0.7)
                                        : Colors.blueAccent.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    chatMessages[index]["text"],
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  hintText: 'Type a message...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  fillColor: Colors.white.withOpacity(0.3),
                                  filled: true,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.send),
                              onPressed: _sendMessage,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        )
    );
  }
}