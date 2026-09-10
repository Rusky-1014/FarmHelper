import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  static Interpreter? interpreter;

  static Future<void> loadModel(String crop) async {
    try {
      if (interpreter != null) {
        interpreter!.close();
        interpreter = null;
      }

      String modelPath;
      switch (crop.toLowerCase()) {
        case "mango":
          modelPath = "assets/models/mango.tflite";
          break;
        case "grape":
          modelPath = "assets/models/grape.tflite";
          break;
        default:
          throw Exception("Unknown crop: $crop");
      }

      debugPrint("Loading model: $modelPath");

      final options = InterpreterOptions()..threads = 2;

      interpreter = await Interpreter.fromAsset(
        modelPath,
        options: options,
      );

      debugPrint("✓ Model loaded");
      debugPrint(
          "Input shape: ${interpreter!.getInputTensor(0).shape}");
      debugPrint(
          "Output shape: ${interpreter!.getOutputTensor(0).shape}");
    } catch (e, st) {
      debugPrint("MODEL LOADING ERROR: $e\n$st");
      rethrow;
    }
  }

  /// [inputBuffer] must be a Float32List of length 1*224*224*3 = 150528
  static List<double> predict(
    Float32List inputBuffer,
    int numClasses,
  ) {
    if (interpreter == null) throw Exception("Model not loaded");

    // Reshape input to [1, 224, 224, 3] as a flat typed buffer
    // tflite_flutter accepts Float32List directly for single-input models
    final inputTensor = inputBuffer.reshape([1, 224, 224, 3]);

    final output = [List.filled(numClasses, 0.0)];

    interpreter!.run(inputTensor, output);

    return List<double>.from(output[0]);
  }

  static void closeModel() {
    interpreter?.close();
    interpreter = null;
  }
}