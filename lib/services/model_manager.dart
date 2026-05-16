import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ModelManager {
  static final ModelManager _instance = ModelManager._internal();
  factory ModelManager() => _instance;
  ModelManager._internal();

  Future<String> getModelPath(String modelName) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String modelDir = '${appDocDir.path}/models';
    if (!await Directory(modelDir).exists()) {
      await Directory(modelDir).create(recursive: true);
    }
    return '$modelDir/$modelName';
  }

  Future<bool> isModelAvailable(String modelName) async {
    String path = await getModelPath(modelName);
    return await File(path).exists();
  }

  /// Copies a model from assets to the local filesystem for native inference.
  Future<void> ensureModelFromAssets(String modelName) async {
    String destinationPath = await getModelPath(modelName);
    if (await File(destinationPath).exists()) return;

    try {
      ByteData data = await rootBundle.load('assets/models/$modelName');
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(destinationPath).writeAsBytes(bytes);
      print("Model $modelName copied to local storage.");
    } catch (e) {
      print("Error copying model $modelName from assets: $e");
    }
  }

  Future<void> downloadModel(String modelName, String url) async {
    String path = await getModelPath(modelName);
    if (await isModelAvailable(modelName)) return;

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      await File(path).writeAsBytes(response.bodyBytes);
    } else {
      throw Exception('Failed to download model: $modelName');
    }
  }
}
