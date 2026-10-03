import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Copies bundled assets to real files on disk so native
/// libraries (sherpa-onnx) can open them by path.
class AssetFileService {
  AssetFileService._();

  /// Returns a local file path for [assetPath], copying it
  /// out of the APK the first time.
  ///
  /// The copy is written to a temporary file and renamed
  /// only when complete, and the size is re-checked on every
  /// call, so a copy interrupted by the app being killed is
  /// never mistaken for a valid model file.
  /// In-flight and completed copies, so concurrent callers
  /// share one copy instead of racing on the same file.
  static final Map<String, Future<String>> _resolved = {};

  static Future<String> copyAssetToLocal(String assetPath) {
    return _resolved[assetPath] ??= _copy(assetPath).catchError((Object e) {
      _resolved.remove(assetPath);
      throw e;
    });
  }

  static Future<String> _copy(String assetPath) async {
    final appDirectory = await getApplicationSupportDirectory();

    final destination = File('${appDirectory.path}/$assetPath');

    await destination.parent.create(recursive: true);

    final data = await rootBundle.load(assetPath);

    if (await destination.exists() &&
        await destination.length() == data.lengthInBytes) {
      return destination.path;
    }

    final temp = File('${destination.path}.part');

    await temp.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      flush: true,
    );

    if (await destination.exists()) {
      await destination.delete();
    }

    await temp.rename(destination.path);

    return destination.path;
  }
}
