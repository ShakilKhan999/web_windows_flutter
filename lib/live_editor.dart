import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'dart:math';
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
    "Interesting point. Could you elaborate?",
    "I see. How does that relate to your previous statement?",
    "That's a unique perspective. What led you to that conclusion?",
    "I understand. What are your thoughts on the implications?",
    "Fascinating. Have you considered alternative viewpoints?",
  ];

  int currentGifIndex = 0;
  bool started=false;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Random _random = Random();
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
        started=true;
        // Add user message
        chatMessages.add({"text": _controller.text, "isUser": true});
        _controller.clear();

        // Start changing background
        _isChangingBackground = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      // Simulate loading for 2 seconds
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          // Change background GIF
          int newGifIndex;
          do {
            newGifIndex = _random.nextInt(gifList.length);
          } while (newGifIndex == currentGifIndex && gifList.length > 1);
          currentGifIndex = newGifIndex;

          // Add AI reply
          String aiResponse = aiReplies[_random.nextInt(aiReplies.length)];
          chatMessages.add({"text": aiResponse, "isUser": false});

          _isChangingBackground = false;
        });

        // Scroll to bottom after setState
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
            if (_isBackgroundLoaded && started==true)
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
                      // Chat list
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
                      // Text input field
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