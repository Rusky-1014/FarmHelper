import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;

import 'asset_file_service.dart';
import 'language_service.dart';

/// Offline text-to-speech using Supertonic 3 (sherpa-onnx).
///
/// Speech synthesis is CPU heavy and takes seconds, so it
/// runs in a background isolate. Running it on the UI
/// isolate froze the whole app after every AI answer.
class TextToSpeechService {
  TextToSpeechService._();

  static const _base = 'assets/tts/supertonic';

  static final AudioPlayer _player = AudioPlayer();

  static _TtsPaths? _paths;
  static StreamSubscription<void>? _completion;

  static bool _speaking = false;

  /// Incremented on every speak()/stop() so a slow synthesis
  /// that finishes after the user pressed stop is discarded.
  static int _generation = 0;

  static bool get isInitialized => _paths != null;

  static bool get isSpeaking => _speaking;

  /// Copies the model files out of the APK (first run only).
  static Future<void> initialize() async {
    if (_paths != null) {
      return;
    }

    _paths = _TtsPaths(
      durationPredictor: await AssetFileService.copyAssetToLocal(
          '$_base/duration_predictor.int8.onnx'),
      textEncoder: await AssetFileService.copyAssetToLocal(
          '$_base/text_encoder.int8.onnx'),
      vectorEstimator: await AssetFileService.copyAssetToLocal(
          '$_base/vector_estimator.int8.onnx'),
      vocoder:
          await AssetFileService.copyAssetToLocal('$_base/vocoder.int8.onnx'),
      ttsJson: await AssetFileService.copyAssetToLocal('$_base/tts.json'),
      unicodeIndexer:
          await AssetFileService.copyAssetToLocal('$_base/unicode_indexer.bin'),
      voiceStyle: await AssetFileService.copyAssetToLocal('$_base/voice.bin'),
    );

    debugPrint('TextToSpeechService: Supertonic files ready.');
  }

  /// Whether the Supertonic model can speak [language].
  static bool supportsLanguage(String language) {
    return LanguageService.supportsOfflineTts(language);
  }

  /// Generates and plays offline speech.
  ///
  /// Returns true once playback has started, false if the
  /// language is unsupported or the request was superseded.
  static Future<bool> speak(
    String text, {
    String language = 'en',
    double speed = 1.0,
  }) async {
    final cleanText = cleanForSpeech(text);

    if (cleanText.isEmpty || !supportsLanguage(language)) {
      return false;
    }

    await stop();
    final myGeneration = ++_generation;

    await initialize();

    final directory = await getTemporaryDirectory();
    final outputPath = '${directory.path}/farmhelper_tts_$myGeneration.wav';

    _speaking = true;

    final paths = _paths!;

    final written = await Isolate.run(
      () => _synthesize(paths, cleanText, language, speed, outputPath),
    );

    if (myGeneration != _generation) {
      // stop() or a newer speak() happened meanwhile.
      _deleteQuietly(outputPath);
      return false;
    }

    if (!written) {
      _speaking = false;
      throw Exception('TTS could not generate audio.');
    }

    await _completion?.cancel();
    _completion = _player.onPlayerComplete.listen((_) {
      _speaking = false;
      _deleteQuietly(outputPath);
    });

    try {
      await _player.play(DeviceFileSource(outputPath));
      return true;
    } catch (_) {
      _speaking = false;
      rethrow;
    }
  }

  static Future<void> stop() async {
    _generation++;
    try {
      await _player.stop();
    } catch (_) {
    } finally {
      _speaking = false;
    }
  }

  static Future<void> dispose() async {
    await stop();
    await _completion?.cancel();
    await _player.dispose();
  }

  /// Removes markdown and symbols that the model would
  /// otherwise read out loud, and caps very long answers.
  static String cleanForSpeech(String text) {
    var value = text
        .replaceAll(RegExp(r'[*#_`>|~]'), ' ')
        .replaceAll(RegExp(r'^\s*[-•]\s*', multiLine: true), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    const maxChars = 600;
    if (value.length > maxChars) {
      final cut = value.lastIndexOf(RegExp(r'[.!?।]'), maxChars);
      value = value.substring(0, cut > 100 ? cut + 1 : maxChars);
    }

    return value;
  }

  static void _deleteQuietly(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) file.deleteSync();
    } catch (_) {}
  }
}

class _TtsPaths {
  final String durationPredictor;
  final String textEncoder;
  final String vectorEstimator;
  final String vocoder;
  final String ttsJson;
  final String unicodeIndexer;
  final String voiceStyle;

  const _TtsPaths({
    required this.durationPredictor,
    required this.textEncoder,
    required this.vectorEstimator,
    required this.vocoder,
    required this.ttsJson,
    required this.unicodeIndexer,
    required this.voiceStyle,
  });
}

/// Runs inside a background isolate.
bool _synthesize(
  _TtsPaths paths,
  String text,
  String language,
  double speed,
  String outputPath,
) {
  sherpa_onnx.initBindings();

  final config = sherpa_onnx.OfflineTtsConfig(
    model: sherpa_onnx.OfflineTtsModelConfig(
      supertonic: sherpa_onnx.OfflineTtsSupertonicModelConfig(
        durationPredictor: paths.durationPredictor,
        textEncoder: paths.textEncoder,
        vectorEstimator: paths.vectorEstimator,
        vocoder: paths.vocoder,
        ttsJson: paths.ttsJson,
        unicodeIndexer: paths.unicodeIndexer,
        voiceStyle: paths.voiceStyle,
      ),
      numThreads: 2,
      debug: false,
      provider: 'cpu',
    ),
    maxNumSenetences: 1,
  );

  final tts = sherpa_onnx.OfflineTts(config);

  try {
    final audio = tts.generateWithConfig(
      text: text,
      config: sherpa_onnx.OfflineTtsGenerationConfig(
        sid: 0,
        speed: speed,
        numSteps: 8,
        extra: {'lang': language},
      ),
    );

    if (audio.samples.isEmpty) {
      return false;
    }

    return sherpa_onnx.writeWave(
      filename: outputPath,
      samples: audio.samples,
      sampleRate: audio.sampleRate,
    );
  } finally {
    tts.free();
  }
}
