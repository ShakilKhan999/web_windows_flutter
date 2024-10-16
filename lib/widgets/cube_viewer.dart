import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';

class CubeViewer extends StatelessWidget {
  final String filePath;

  CubeViewer({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 500,
      child: Cube(
        onSceneCreated: (Scene scene) {
          scene.world
              .add(Object(fileName: filePath, isAsset: false, lighting: true));
          scene.camera.zoom = 10;
          scene.light.position.setFrom(Vector3(0, 5, 5));
          scene.light.setColor(Color.fromARGB(255, 180, 180, 180), 1, 0.5, 0.3);
          scene.camera.target.setFrom(Vector3(0, 0, 0));
          scene.update();
        },
      ),
    );
  }
}
