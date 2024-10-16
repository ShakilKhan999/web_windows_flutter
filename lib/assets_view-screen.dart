// lib/screens/asset_view_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_windows/save_model.dart';

import '../widgets/cube_viewer.dart';

class AssetView extends StatefulWidget {
  @override
  _AssetViewState createState() => _AssetViewState();
}

class _AssetViewState extends State<AssetView> {
  List<String> savedModels = [];

  @override
  void initState() {
    super.initState();
    _loadSavedModels();
  }

  Future<void> _loadSavedModels() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedModels = prefs.getStringList('saved_models') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Assets'),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.75,
        ),
        itemCount: savedModels.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SavedModelViewer(
                      savedModels: savedModels, initialIndex: index),
                ),
              );
            },
            child: Card(
              elevation: 4,
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(4)),
                      child: CubeViewer(
                        filePath: savedModels[index],
                        // interactive: false, // Disable interaction for preview
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Text(
                          'Model ${index + 1}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          savedModels[index].split('/').last,
                          style: TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
