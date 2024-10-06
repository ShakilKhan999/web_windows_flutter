import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:http/http.dart' as http;

class MusicGenerateScreen extends StatefulWidget {
  @override
  _MusicGenerateScreenState createState() => _MusicGenerateScreenState();
}

class _MusicGenerateScreenState extends State<MusicGenerateScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  bool isGenerating = false;
  bool showMusicPlayer = false;
  String? audioUrl;
  int durationInSeconds = 15; // Initially set to 15 seconds

  @override
  void initState() {
    super.initState();
    _audioPlayer.onDurationChanged.listen((Duration newDuration) {
      setState(() {
        totalDuration = newDuration;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration newPosition) {
      setState(() {
        currentPosition = newPosition;
      });
    });

    // Add listener to text controller to update UI when text changes
    _searchController.addListener(() {
      setState(() {}); // This will rebuild the UI when text changes
    });
  }

  Future<void> generateMusic() async {
    if (_searchController.text.isEmpty) return; // Prevent generation if text is empty

    setState(() {
      isGenerating = true;
      showMusicPlayer = false;
    });

    var url = Uri.parse("https://api.musicfy.lol/v1/generate-music");
    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer cm1pfpuwz0001l80ct64ar3xe"
    };
    var body = jsonEncode({
      "prompt": _searchController.text,
      "duration": durationInSeconds
    });

    try {
      var response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        audioUrl = jsonResponse[0]['file_url'];
        await _audioPlayer.setSourceUrl(audioUrl!);
        setState(() {
          isGenerating = false;
          showMusicPlayer = true;
        });
      } else {
        print("Failed: ${response.statusCode}, ${response.body}");
        setState(() {
          isGenerating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate music. Please try again.')),
        );
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isGenerating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  void _playPauseMusic() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void _seekMusic(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple[900]!, Colors.black],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Music Generator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Type text to generate music...',
                          hintStyle: TextStyle(color: Colors.white60),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.music_note, color: Colors.white60),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                if (durationInSeconds > 1) durationInSeconds--;
                              });
                            },
                          ),
                          Text(
                            '$durationInSeconds s',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                durationInSeconds++;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: (_searchController.text.isNotEmpty && !isGenerating)
                        ? generateMusic
                        : null, // Disable button if text is empty or generating
                    child: Text('Generate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      disabledBackgroundColor: Colors.grey, // Color when disabled
                    ),
                  ),
                ),
                SizedBox(height: 10),
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
                          : showMusicPlayer
                          ? _buildMusicPlayerUI()
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
      children: [
        Icon(
          Icons.music_note,
          size: 80,
          color: Colors.white,
        ),
        SizedBox(height: 20),
        Text(
          'Generate your own music with AI',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        Text(
          'Enter a prompt and set the duration, then click Generate.',
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
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
        SizedBox(height: 20),
        Text(
          'Generating your music...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 20),
        LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
          backgroundColor: Colors.white.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildMusicPlayerUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 70,
          height: 65,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.purpleAccent, Colors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.purpleAccent.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.music_note,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 5),
        Text(
          'AI Generated Music',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.skip_previous,
                size: 25,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
            SizedBox(width: 15),
            GestureDetector(
              onTap: _playPauseMusic,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 25,
                  color: Colors.deepPurple[900],
                ),
              ),
            ),
            SizedBox(width: 20),
            IconButton(
              icon: Icon(
                Icons.skip_next,
                size: 40,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ],
        ),
        SizedBox(height: 20),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withOpacity(0.3),
            thumbColor: Colors.white,
            overlayColor: Colors.white.withOpacity(0.3),
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: currentPosition.inSeconds.toDouble(),
            max: totalDuration.inSeconds.toDouble(),
            onChanged: _seekMusic,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(currentPosition),
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                _formatDuration(totalDuration),
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}