import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class AnimationGenerateScreen extends StatefulWidget {
  const AnimationGenerateScreen({Key? key}) : super(key: key);

  @override
  _AnimationGenerateScreenState createState() => _AnimationGenerateScreenState();
}

class _AnimationGenerateScreenState extends State<AnimationGenerateScreen> {
  final TextEditingController _promptController = TextEditingController();
  bool isGenerating = false;
  bool showAnimationPlayer = false;

  @override
  void initState() {
    super.initState();
    _promptController.addListener(() {
      setState(() {}); // This will rebuild the UI when text changes
    });
  }

  Future<void> generateAnimation() async {
    if (_promptController.text.isEmpty) return;

    setState(() {
      isGenerating = true;
      showAnimationPlayer = false;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      isGenerating = false;
      showAnimationPlayer = true;
    });
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
                const Text(
                  'AI Animation Generator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
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
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: (_promptController.text.isNotEmpty && !isGenerating)
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
                  ],
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
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
          backgroundColor: Colors.white.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildAnimationPlayerUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 200,
          height: 170,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.movie,
            size: 100,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Your Animation',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit),
              label: const Text('Adjust'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}