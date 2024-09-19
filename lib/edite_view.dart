import 'package:flutter/material.dart';

class Asset {
  final String name;
  final String category;
  final String imagePath;
  final double price;

  Asset({
    required this.name,
    required this.category,
    required this.imagePath,
    required this.price,
  });
}

class FolderNode {
  String name;
  List<FolderNode> children;
  bool isExpanded;
  IconData icon;

  FolderNode({
    required this.name,
    this.children = const [],
    this.isExpanded = false,
    this.icon = Icons.folder,
  });
}

class EditPage extends StatefulWidget {
  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final List<Asset> assets = [
    // 3D Models
    Asset(
        name: 'Character',
        category: '3D models',
        imagePath: 'assets/images/1.png',
        price: 2.99),
    Asset(
        name: 'Car',
        category: '3D models',
        imagePath: 'assets/images/2.png',
        price: 3.99),
    Asset(
        name: 'PC',
        category: '3D models',
        imagePath: 'assets/images/3.png',
        price: 4.99),
    Asset(
        name: 'GUN',
        category: '3D models',
        imagePath: 'assets/images/4.png',
        price: 5.99),

    // Materials
    Asset(
        name: 'Rusty metal',
        category: 'Materials',
        imagePath: 'assets/images/5.png',
        price: 1.99),
    Asset(
        name: 'Skin',
        category: 'Materials',
        imagePath: 'assets/images/6.png',
        price: 2.99),
    Asset(
        name: 'Space suit fabric',
        category: 'Materials',
        imagePath: 'assets/images/1.png',
        price: 3.99),
    Asset(
        name: 'Carbon fiber',
        category: 'Materials',
        imagePath: 'assets/images/2.png',
        price: 4.99),

    // Sound effects
    Asset(
        name: 'Explosion',
        category: 'Sound effects',
        imagePath: 'assets/images/3.png',
        price: 1.99),
    Asset(
        name: 'Laser beam',
        category: 'Sound effects',
        imagePath: 'assets/images/4.png',
        price: 2.99),
    Asset(
        name: 'Alien chatter',
        category: 'Sound effects',
        imagePath: 'assets/images/5.png',
        price: 3.99),
    Asset(
        name: 'Rocket launch',
        category: 'Sound effects',
        imagePath: 'assets/images/6.png',
        price: 4.99),
  ];

  List<FolderNode> folderStructure = [
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
      FolderNode(name: 'Scripts'),
    ]),
  ];

  String? selectedCategory;
  String? droppedImagePath;

  @override
  void initState() {
    super.initState();
    selectedCategory = assets.first.category;
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
                    Icon(node.children.isEmpty
                        ? Icons.insert_drive_file
                        : node.isExpanded
                            ? Icons.folder_open
                            : Icons.folder),
                    SizedBox(width: 8),
                    Text(node.name),
                  ],
                ),
                if (node.children.isNotEmpty)
                  Icon(node.isExpanded
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down)
              ],
            ),
          ),
        ),
        if (node.isExpanded)
          ...node.children.map((child) => _buildFolderTree(child, depth + 1)),
      ],
    );
  }

  Widget _buildDraggableAsset(Asset asset) {
    return Draggable<String>(
      data: asset.imagePath,
      child: _buildAssetThumbnail(asset),
      feedback: _buildDragFeedback(asset),
      childWhenDragging: _buildAssetThumbnail(asset, opacity: 0.5),
    );
  }

  Widget _buildDragFeedback(Asset asset) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(asset.imagePath),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetThumbnail(Asset asset, {double opacity = 1.0}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 100,
        height: 120,
        margin: EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 70,
              width: 100,
              child: Image.asset(
                asset.imagePath,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 4),
            Text(
              asset.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12),
            ),
            Text(
              '\$${asset.price.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 12),
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
        margin: EdgeInsets.all(8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: assets.length,
          itemBuilder: (context, index) => _buildDraggableAsset(assets[index]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            // Wide layout
            return Row(
              children: [
                // Left side: Folder Tree
                Container(
                  width: 250,
                  height: MediaQuery.of(context).size.height,
                  child: Card(
                    margin: EdgeInsets.all(8),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: folderStructure
                            .map((node) => _buildFolderTree(node))
                            .toList(),
                      ),
                    ),
                  ),
                ),
                // Right side: UI Area and Asset Lists
                Expanded(
                  child: Column(
                    children: [
                      // UI Area
                      Expanded(
                        child: DragTarget<String>(
                          builder: (context, candidateData, rejectedData) {
                            return Card(
                              margin: EdgeInsets.all(8),
                              child: Center(
                                child: droppedImagePath != null
                                    ? Image.asset(droppedImagePath!)
                                    : Text('Drag an image here'),
                              ),
                            );
                          },
                          onAccept: (imagePath) {
                            setState(() {
                              droppedImagePath = imagePath;
                            });
                          },
                        ),
                      ),
                      // Asset Lists
                      _buildAssetList(),
                      SizedBox(height: 10),
                      _buildAssetList(),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // Narrow layout
            return Column(
              children: [
                // Top: Folder Tree
                Container(
                  height: 200,
                  child: Card(
                    margin: EdgeInsets.all(8),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: folderStructure
                            .map((node) => _buildFolderTree(node))
                            .toList(),
                      ),
                    ),
                  ),
                ),
                // Middle: UI Area
                Expanded(
                  child: DragTarget<String>(
                    builder: (context, candidateData, rejectedData) {
                      return Card(
                        margin: EdgeInsets.all(8),
                        child: Center(
                          child: droppedImagePath != null
                              ? Image.asset(droppedImagePath!)
                              : Text('Drag an image here'),
                        ),
                      );
                    },
                    onAccept: (imagePath) {
                      setState(() {
                        droppedImagePath = imagePath;
                      });
                    },
                  ),
                ),
                // Bottom: Asset Lists
                _buildAssetList(),
                SizedBox(height: 10),
                _buildAssetList(),
              ],
            );
          }
        },
      ),
    );
  }
}
