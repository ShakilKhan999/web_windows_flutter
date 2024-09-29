import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class LiveEditor extends StatefulWidget {
  const LiveEditor({super.key});

  @override
  State<LiveEditor> createState() => _LiveEditorState();
}

class _LiveEditorState extends State<LiveEditor> {
  List<String> chatMessages = [
    "What can I help you with?",
  ];

  final TextEditingController _controller = TextEditingController();
  bool _isBackgroundLoaded = false;

  // Method to add new message to the chat list and trigger background load
  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        chatMessages.add(_controller.text);
        _controller.clear();
        if (!_isBackgroundLoaded) {
          _isBackgroundLoaded = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            if (_isBackgroundLoaded)
              Image.asset(
                "assets/gif/doomgif.gif",
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              )
            else
              Center(
                child: CircularProgressIndicator(),
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
                          itemCount: chatMessages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: index % 2 == 0
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: index % 2 == 0
                                        ? Colors.blueAccent.withOpacity(0.7)
                                        : Colors.greenAccent.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    chatMessages[index],
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