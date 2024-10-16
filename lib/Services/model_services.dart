import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModelService {
  static const String API_KEY = 'msy_5wFEvF64qc9zCLYY9vbTnfP5QZgAhtAjQIS8';

  static Future<String> generateModel(
      String prompt, Function(int) onProgress) async {
    // Step 1: Make a single POST request
    final postResponse = await http.post(
      Uri.parse('https://api.meshy.ai/v2/text-to-3d'),
      headers: {
        'Authorization': 'Bearer $API_KEY',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "mode": "preview",
        "prompt": prompt,
        "art_style": "realistic",
        "negative_prompt": "low quality, low resolution, low poly, ugly"
      }),
    );

    if (postResponse.statusCode != 202) {
      throw Exception('Failed to generate model: ${postResponse.statusCode}');
    }

    final postResult = jsonDecode(postResponse.body);
    final String modelId = postResult['result'];

    // Step 2: Poll the GET API until progress is 100% and OBJ URL is available
    String? objUrl;
    while (true) {
      await Future.delayed(Duration(seconds: 3));

      final getResponse = await http.get(
        Uri.parse('https://api.meshy.ai/v2/text-to-3d/$modelId'),
        headers: {
          'Authorization': 'Bearer $API_KEY',
        },
      );

      if (getResponse.statusCode != 200) {
        throw Exception('Failed to poll model: ${getResponse.statusCode}');
      }

      final getResult = jsonDecode(getResponse.body);
      onProgress(getResult['progress']);

      if (getResult['progress'] == 100) {
        objUrl = getResult['model_urls']['obj'];
        if (objUrl != null) {
          break;
        } else {
          throw Exception('OBJ URL not found in the response');
        }
      }
    }

    // Step 3: Download and save the OBJ file
    final response = await http.get(Uri.parse(objUrl!));
    if (response.statusCode == 200) {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
          '${directory.path}/model_${DateTime.now().millisecondsSinceEpoch}.obj');
      await file.writeAsBytes(response.bodyBytes);

      // Save the file path to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      List<String> savedModels = prefs.getStringList('saved_models') ?? [];
      savedModels.add(file.path);
      await prefs.setStringList('saved_models', savedModels);

      return file.path;
    } else {
      throw Exception(
          'Failed to download the file. Status code: ${response.statusCode}');
    }
  }
}
