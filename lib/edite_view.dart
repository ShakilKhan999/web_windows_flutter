import 'package:flutter/material.dart';
import 'package:gif/gif.dart';

class Asset {
  final String name;
  final String category;
  final String imagePath;
  final double price;
  final bool isGif;

  Asset({
    required this.name,
    required this.category,
    required this.imagePath,
    required this.price,
    this.isGif = false,
  });
}

class FolderNode {
  String name;
  List<FolderNode> children;
  List<Asset> assets;
  bool isExpanded;
  IconData icon;

  FolderNode({
    required this.name,
    this.children = const [],
    this.assets = const [],
    this.isExpanded = false,
    this.icon = Icons.folder,
  });
}

class EditPage extends StatefulWidget {
  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> with TickerProviderStateMixin {
  final List<Asset> assets = [
    Asset(
        name: 'gif.gif',
        category: 'GIF',
        imagePath: 'assets/gif/gif.gif',
        price: 1.99,
        isGif: true),
    Asset(
        name: 'gif2.gif',
        category: 'GIF',
        imagePath: 'assets/gif/gif.gif',
        price: 2.99,
        isGif: true),
    Asset(
        name: 'gif3.gif',
        category: 'GIF',
        imagePath: 'assets/gif/1.gif',
        price: 2.99,
        isGif: true),
    Asset(
        name: 'gif4.gif',
        category: 'GIF',
        imagePath: 'assets/gif/2.gif',
        price: 2.99,
        isGif: true),
    Asset(
        name: 'gif5.gif',
        category: 'GIF',
        imagePath: 'assets/gif/3.gif',
        price: 2.99,
        isGif: true),
    Asset(
        name: 'gif6.gif',
        category: 'GIF',
        imagePath: 'assets/gif/4.gif',
        price: 2.99,
        isGif: true),
  ];

  late List<FolderNode> folderStructure;
  late Map<String, GifController> _staticGifControllers;
  late Map<String, GifController> _animatedGifControllers;

  String? selectedCategory;
  String? droppedImagePath;

  @override
  void initState() {
    super.initState();
    selectedCategory = assets.first.category;
    _initializeFolderStructure();
    _initializeGifControllers();
  }

  void _initializeFolderStructure() {
    folderStructure = [
      FolderNode(name: 'Project', children: [
        FolderNode(name: '3D Models', children: [
          FolderNode(name: 'Characters'),
          FolderNode(name: 'Vehicles'),
          FolderNode(name: 'Props'),
        ]),
        FolderNode(name: 'Materials', children: [
          FolderNode(name: 'Metals'),
          FolderNode(name: 'Fabrics'),
        ]),
        FolderNode(name: 'Sound Effects', children: [
          FolderNode(name: 'Ambience'),
          FolderNode(name: 'Actions'),
        ]),
        FolderNode(name: 'Assets', children: []),
      ]),
    ];
  }

  void _initializeGifControllers() {
    _staticGifControllers = {};
    _animatedGifControllers = {};
    for (var asset in assets.where((a) => a.isGif)) {
      _staticGifControllers[asset.imagePath] = GifController(vsync: this);
      _animatedGifControllers[asset.imagePath] = GifController(vsync: this);
    }
  }

  @override
  void dispose() {
    for (var controller in _staticGifControllers.values) {
      controller.dispose();
    }
    for (var controller in _animatedGifControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildFolderTree(FolderNode node, [int depth = 0]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              node.isExpanded = !node.isExpanded;
            });
          },
          child: Padding(
            padding: EdgeInsets.only(
                left: depth * 20.0, top: 8, bottom: 8, right: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(node.children.isEmpty && node.assets.isEmpty
                        ? Icons.insert_drive_file
                        : node.isExpanded
                            ? Icons.folder_open
                            : Icons.folder),
                    const SizedBox(width: 8),
                    Text(node.name),
                  ],
                ),
                if (node.children.isNotEmpty || node.assets.isNotEmpty)
                  Icon(node.isExpanded
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down)
              ],
            ),
          ),
        ),
        if (node.isExpanded) ...[
          ...node.children.map((child) => _buildFolderTree(child, depth + 1)),
          ...node.assets.map((asset) => _buildGifAsset(asset, depth + 1)),
        ],
      ],
    );
  }

  Widget _buildGifAsset(Asset asset, int depth) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 20.0, top: 4, bottom: 4),
      child: _buildDraggableAsset(asset, isInFolderTree: true),
    );
  }

  Widget _buildDraggableAsset(Asset asset,
      {bool isInFolderTree = false, bool isInAssetList = false}) {
    return Draggable<String>(
      data: asset.imagePath,
      feedback: _buildDragFeedback(asset),
      childWhenDragging: _buildAssetThumbnail(
        asset,
        opacity: 0.5,
        isInFolderTree: isInFolderTree,
        isInAssetList: isInAssetList,
      ),
      child: _buildAssetThumbnail(asset,
          isInFolderTree: isInFolderTree, isInAssetList: isInAssetList),
    );
  }

  Widget _buildDragFeedback(Asset asset) {
    return Container(
      width: 100,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: asset.isGif
            ? Gif(
                image: AssetImage(asset.imagePath),
                controller: _staticGifControllers[asset.imagePath]!,
                fps: 10,
                autostart: Autostart.once,
                placeholder: (context) => const CircularProgressIndicator(),
                onFetchCompleted: () {
                  _staticGifControllers[asset.imagePath]!.reset();
                },
              )
            : Image.asset(
                asset.imagePath,
                gaplessPlayback: true,
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  Widget _buildAssetThumbnail(Asset asset,
      {double opacity = 1.0,
      bool isInFolderTree = false,
      bool isInAssetList = false}) {
    return Opacity(
      opacity: opacity,
      child: asset.isGif && isInFolderTree
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  asset.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 5),
              ],
            )
          : Container(
              width: 100,
              height: 120,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 70,
                    width: 100,
                    child: asset.isGif
                        ? Gif(
                            image: AssetImage(asset.imagePath),
                            controller: _staticGifControllers[asset.imagePath]!,
                            fps: 10,
                            autostart: Autostart.once,
                            placeholder: (context) =>
                                const CircularProgressIndicator(),
                            onFetchCompleted: () {
                              _staticGifControllers[asset.imagePath]?.reset();
                            },
                          )
                        : Image.asset(
                            asset.imagePath,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Text(
                    asset.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    '\$${asset.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAssetList() {
    return Container(
      height: 130,
      child: Card(
        margin: const EdgeInsets.all(8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: assets.length,
          itemBuilder: (context, index) =>
              _buildDraggableAsset(assets[index], isInAssetList: true),
        ),
      ),
    );
  }

  Widget _buildDroppedAsset(String imagePath) {
    Asset asset = assets.firstWhere(
      (a) => a.imagePath == imagePath,
      orElse: () => Asset(
        name: 'Unknown',
        category: 'Unknown',
        imagePath: imagePath,
        price: 0.0,
      ),
    );

    if (asset.isGif) {
      if (_animatedGifControllers.containsKey(asset.imagePath)) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Gif(
            image: AssetImage(asset.imagePath),
            controller: _animatedGifControllers[asset.imagePath]!,
            fps: 10,
            autostart: Autostart.loop,
            placeholder: (context) =>
                Center(child: const CircularProgressIndicator()),
            onFetchCompleted: () {
              _animatedGifControllers[asset.imagePath]?.reset();
              _animatedGifControllers[asset.imagePath]?.forward();
            },
          ),
        );
      } else {
        return Text('GIF controller not found for ${asset.name}');
      }
    } else {
      return Image.asset(imagePath, fit: BoxFit.contain);
    }
  }

  Widget _buildTabBar(List<String> tabs) {
    return Container(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey),
              ),
            ),
            child: Text(tabs[index], style: const TextStyle(fontSize: 12)),
          );
        },
      ),
    );
  }

  Widget _buildInspectorPanel() {
    return ListView(
      children: [
        ExpansionTile(
          title: const Text('Transform'),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Row(
                children: [
                  const Text('Position:'),
                  const SizedBox(width: 3),
                  Row(
                    children: [
                      const Text('x'),
                      const SizedBox(width: 3),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: const Color.fromARGB(255, 83, 83, 83),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('10.762'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 3),
                  Row(
                    children: [
                      const Text('y'),
                      const SizedBox(width: 3),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: const Color.fromARGB(255, 83, 83, 83),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('333.436'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 3),
                  Row(
                    children: [
                      const Text('z'),
                      const SizedBox(width: 3),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: const Color.fromARGB(255, 83, 83, 83),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('31.591'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Add more Transform details here...
          ],
        ),
        const ExpansionTile(
          title: Text('Animator'),
          children: [
            ListTile(title: Text('Controller: None')),
            ListTile(title: Text('Avatar: None')),
            ListTile(title: Text('Apply Root Motion')),
            ListTile(title: Text('Update Mode: Normal')),
          ],
        ),
        const ExpansionTile(
          title: Text('Capsule Collider'),
          children: [
            ListTile(title: Text('Is Trigger: false')),
            ListTile(title: Text('Material: None (Physic Material)')),
            ListTile(title: Text('Center: X 0 Y 0.9 Z 0')),
            ListTile(title: Text('Radius: 0.3')),
            ListTile(title: Text('Height: 1.8')),
            ListTile(title: Text('Direction: Y-Axis')),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: folderStructure.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Left panel (Hierarchy)
                Container(
                  width: 250,
                  child: Column(
                    children: [
                      _buildTabBar(['Hierarchy', 'Project', 'Console']),
                      Expanded(
                        child: Card(
                          margin: const EdgeInsets.all(8),
                          child: ListView(
                            children: folderStructure
                                .map((node) => _buildFolderTree(node))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Center panel (Scene view)
                Expanded(
                  child: Column(
                    children: [
                      _buildTabBar(['Scene', 'Game']),
                      Expanded(
                        child: DragTarget<String>(
                          builder: (context, candidateData, rejectedData) {
                            return Card(
                              margin: const EdgeInsets.all(8),
                              child: Center(
                                child: droppedImagePath != null
                                    ? _buildDroppedAsset(droppedImagePath!)
                                    : const Text('Scene View'),
                              ),
                            );
                          },
                          onAccept: (imagePath) {
                            setState(() {
                              droppedImagePath = imagePath;
                              if (_animatedGifControllers[imagePath] != null) {
                                _animatedGifControllers[imagePath]!.reset();
                                _animatedGifControllers[imagePath]!.forward();
                              }
                            });
                          },
                        ),
                      ),
                      _buildAssetList(),
                      SizedBox(height: 10),
                      _buildAssetList(),
                    ],
                  ),
                ),
                // Right panel (Inspector)
                Container(
                  width: 300,
                  child: Column(
                    children: [
                      _buildTabBar(['Inspector', 'Services']),
                      Expanded(
                        child: Card(
                          margin: const EdgeInsets.all(8),
                          child: _buildInspectorPanel(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
