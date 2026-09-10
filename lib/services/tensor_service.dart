import 'dart:typed_data';
import 'package:image/image.dart' as img;

class TensorService {
  /// Builds a Float32List input buffer shaped [1, 224, 224, 3]
  /// that tflite_flutter can correctly interpret.
  static Float32List rgbBuffer(img.Image image) {
    // Must be exactly 1 * 224 * 224 * 3 = 150528 floats
    final buffer = Float32List(1 * 224 * 224 * 3);
    int idx = 0;
    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final p = image.getPixel(x, y);
        buffer[idx++] = p.r / 255.0;
        buffer[idx++] = p.g / 255.0;
        buffer[idx++] = p.b / 255.0;
      }
    }
    return buffer;
  }
}