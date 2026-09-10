import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart'
    as sherpa_onnx;

import 'language_service.dart';

class TextToSpeechService {
  TextToSpeechService._();

  static sherpa_onnx.OfflineTts? _tts;

  static final AudioPlayer _player =
      AudioPlayer();

  static bool _initialized = false;
  static bool _speaking = false;

  static bool get isInitialized =>
      _initialized;

  static bool get isSpeaking =>
      _speaking;

  static Future<String> _copyAssetToLocal(
    String assetPath,
  ) async {
    final appDirectory =
        await getApplicationSupportDirectory();

    final destination = File(
      '${appDirectory.path}/$assetPath',
    );

    await destination.parent.create(
      recursive: true,
    );

    if (!await destination.exists()) {
      final data =
          await rootBundle.load(assetPath);

      final bytes =
          data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      await destination.writeAsBytes(
        bytes,
        flush: true,
      );
    }

    return destination.path;
  }

  static Future<void> initialize() async {
    if (_initialized && _tts != null) {
      return;
    }

    try {
      await sherpa_onnx.initBindingsAsync();

      const base =
          'assets/tts/supertonic';

      final durationPredictor =
          await _copyAssetToLocal(
        '$base/duration_predictor.int8.onnx',
      );

      final textEncoder =
          await _copyAssetToLocal(
        '$base/text_encoder.int8.onnx',
      );

      final vectorEstimator =
          await _copyAssetToLocal(
        '$base/vector_estimator.int8.onnx',
      );

      final vocoder =
          await _copyAssetToLocal(
        '$base/vocoder.int8.onnx',
      );

      final ttsJson =
          await _copyAssetToLocal(
        '$base/tts.json',
      );

      final unicodeIndexer =
          await _copyAssetToLocal(
        '$base/unicode_indexer.bin',
      );

      final voiceStyle =
          await _copyAssetToLocal(
        '$base/voice.bin',
      );

      final supertonic =
          sherpa_onnx
              .OfflineTtsSupertonicModelConfig(
        durationPredictor:
            durationPredictor,
        textEncoder:
            textEncoder,
        vectorEstimator:
            vectorEstimator,
        vocoder:
            vocoder,
        ttsJson:
            ttsJson,
        unicodeIndexer:
            unicodeIndexer,
        voiceStyle:
            voiceStyle,
      );

      final model =
          sherpa_onnx.OfflineTtsModelConfig(
        supertonic: supertonic,
        numThreads: 2,
        debug: false,
        provider: 'cpu',
      );

      final config =
          sherpa_onnx.OfflineTtsConfig(
        model: model,
        maxNumSenetences: 1,
      );

      _tts =
          sherpa_onnx.OfflineTts(
        config,
      );

      _initialized = true;

      print(
        'TextToSpeechService: Supertonic ready.',
      );
    } catch (e) {
      _initialized = false;
      _tts = null;

      print(
        'TextToSpeechService initialization error: $e',
      );

      rethrow;
    }
  }

  /// Returns true if the currently installed
  /// Supertonic model can speak the requested language.
  static bool supportsLanguage(
    String language,
  ) {
    return LanguageService
        .supportsOfflineTts(language);
  }

  /// Generates and plays offline speech.
  ///
  /// English -> Supertonic
  /// Hindi   -> Supertonic
  /// Tamil   -> NOT synthesized by current model
  static Future<bool> speak(
    String text, {
    String language = 'en',
    int speakerId = 0,
    double speed = 1.0,
    int numSteps = 8,
  }) async {
    final cleanText =
        text.trim();

    if (cleanText.isEmpty) {
      return false;
    }

    /*
     * Prevent unsupported Tamil from being sent
     * into Supertonic.
     */
    if (!supportsLanguage(language)) {
      print(
        'TTS: Language "$language" is not supported '
        'by the current Supertonic model.',
      );

      return false;
    }

    await initialize();

    await stop();

    final directory =
        await getTemporaryDirectory();

    final outputPath =
        '${directory.path}/farmhelper_tts.wav';

    final oldFile =
        File(outputPath);

    if (await oldFile.exists()) {
      await oldFile.delete();
    }

    print(
      'TextToSpeechService: Generating $language speech...',
    );

    final generationConfig =
        sherpa_onnx
            .OfflineTtsGenerationConfig(
      sid: speakerId,
      speed: speed,
      numSteps: numSteps,
      extra: {
        'lang': language,
      },
    );

    final audio =
        _tts!.generateWithConfig(
      text: cleanText,
      config: generationConfig,
    );

    if (audio.samples.isEmpty) {
      throw Exception(
        'TTS generated empty audio.',
      );
    }

    final written =
        sherpa_onnx.writeWave(
      filename: outputPath,
      samples: audio.samples,
      sampleRate: audio.sampleRate,
    );

    if (!written) {
      throw Exception(
        'Failed to write generated TTS audio.',
      );
    }

    _speaking = true;

    print(
      'TextToSpeechService: Playing $language speech.',
    );

    late final StreamSubscription<void>
        completionSubscription;

    completionSubscription =
        _player.onPlayerComplete.listen((_) {
      _speaking = false;
      completionSubscription.cancel();
    });

    try {
      await _player.play(
        DeviceFileSource(outputPath),
      );

      return true;
    } catch (e) {
      _speaking = false;

      await completionSubscription.cancel();

      rethrow;
    }
  }

  static Future<void> stop() async {
    try {
      await _player.stop();
    } finally {
      _speaking = false;
    }
  }

  static Future<void> dispose() async {
    await stop();

    try {
      _tts?.free();
    } catch (_) {}

    _tts = null;
    _initialized = false;

    await _player.dispose();
  }
}