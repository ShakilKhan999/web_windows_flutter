import 'package:flutter/material.dart';

class Asset {
  final String name;
  final String category;
  final String imagePath;
  final double price;

  Asset(
      {required this.name,
      required this.category,
      required this.imagePath,
      required this.price});
}

class AssetsView extends StatefulWidget {
  @override
  _AssetsViewState createState() => _AssetsViewState();
}

class _AssetsViewState extends State<AssetsView> {
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

  List<Asset> filteredAssets = [];

  @override
  void initState() {
    super.initState();
    filteredAssets = assets;
  }

  void filterAssets(String query) {
    setState(() {
      filteredAssets = assets
          .where(
              (asset) => asset.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assets'),
        backgroundColor: Colors.grey[850],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search assets',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
                onChanged: filterAssets,
              ),
              SizedBox(height: 20),
              ..._buildCategoryWidgets(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCategoryWidgets() {
    Map<String, List<Asset>> categorizedAssets = {};
    for (var asset in filteredAssets) {
      categorizedAssets.putIfAbsent(asset.category, () => []).add(asset);
    }

    List<Widget> categoryWidgets = [];
    categorizedAssets.forEach((category, assets) {
      categoryWidgets.add(Text(category,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
      categoryWidgets.add(SizedBox(height: 10));
      categoryWidgets.add(
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: assets.map((asset) => _assetCard(asset)).toList(),
        ),
      );
      categoryWidgets.add(SizedBox(height: 20));
    });

    return categoryWidgets;
  }

  Widget _assetCard(Asset asset) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.asset(
              asset.imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.name, style: TextStyle(fontWeight: FontWeight.bold)),
                Text('\$${asset.price.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
