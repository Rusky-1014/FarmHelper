import 'dart:io';
import 'package:image/image.dart' as img;

class ImageService {

  static img.Image preprocessImage(
      File imageFile) {

    final bytes =
        imageFile.readAsBytesSync();

    img.Image image =
        img.decodeImage(bytes)!;

    // IMPORTANT
    image = img.bakeOrientation(image);

    image = img.copyResize(
      image,
      width: 224,
      height: 224,
      interpolation: img.Interpolation.linear,
    );

    return image;
  }
}