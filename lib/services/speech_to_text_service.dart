import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;

import 'asset_file_service.dart';

/// Offline speech-to-text using Whisper tiny (sherpa-onnx).
///
/// Decoding runs in a background isolate so the UI does
/// not freeze while the recording is transcribed.
class SpeechToTextService {
  SpeechToTextService._();

  static const _base = 'assets/speech/whisper';

  static final AudioRecorder _recorder = AudioRecorder();

  static _WhisperPaths? _paths;

  static bool _recording = false;
  static String? _recordingPath;

  static bool get isInitialized => _paths != null;

  static bool get isRecording => _recording;

  /// Copies the model files out of the APK (first run only).
  static Future<void> initialize() async {
    if (_paths != null) {
      return;
    }

    _paths = _WhisperPaths(
      encoder:
          await AssetFileService.copyAssetToLocal('$_base/tiny-encoder.int8.onnx'),
      decoder:
          await AssetFileService.copyAssetToLocal('$_base/tiny-decoder.int8.onnx'),
      tokens: await AssetFileService.copyAssetToLocal('$_base/tiny-tokens.txt'),
    );

    debugPrint('SpeechToTextService: Whisper files ready.');
  }

  static Future<void> startRecording() async {
    if (_recording) {
      return;
    }

    if (!await _recorder.hasPermission()) {
      throw Exception('Microphone permission was denied.');
    }

    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/farmhelper_voice.wav';

    final oldFile = File(path);
    if (await oldFile.exists()) {
      await oldFile.delete();
    }

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: path,
    );

    _recordingPath = path;
    _recording = true;

    // Prepare model files while the farmer is speaking.
    initialize().catchError((Object e) {
      debugPrint('SpeechToTextService: prepare failed: $e');
    });
  }

  static Future<String> stopAndTranscribe() async {
    if (!_recording) {
      return '';
    }

    String? actualPath;

    try {
      actualPath = await _recorder.stop() ?? _recordingPath;
      _recording = false;

      if (actualPath == null || actualPath.isEmpty) {
        return '';
      }

      if (!await File(actualPath).exists()) {
        throw Exception('Recorded audio file was not found.');
      }

      await initialize();

      final paths = _paths!;
      final audioPath = actualPath;

      final text = await Isolate.run(() => _transcribe(paths, audioPath));

      debugPrint('SpeechToTextService result: $text');

      return text;
    } finally {
      _recording = false;
      _recordingPath = null;

      if (actualPath != null) {
        try {
          final file = File(actualPath);
          if (await file.exists()) await file.delete();
        } catch (_) {}
      }
    }
  }

  static Future<void> cancelRecording() async {
    if (!_recording) {
      return;
    }

    try {
      await _recorder.stop();
    } catch (_) {}

    _recording = false;

    final path = _recordingPath;
    _recordingPath = null;

    if (path != null) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
  }

  static void dispose() {
    _recorder.dispose();
    _recording = false;
    _recordingPath = null;
  }
}

class _WhisperPaths {
  final String encoder;
  final String decoder;
  final String tokens;

  const _WhisperPaths({
    required this.encoder,
    required this.decoder,
    required this.tokens,
  });
}

/// Runs inside a background isolate.
String _transcribe(_WhisperPaths paths, String audioPath) {
  sherpa_onnx.initBindings();

  final recognizer = sherpa_onnx.OfflineRecognizer(
    sherpa_onnx.OfflineRecognizerConfig(
      model: sherpa_onnx.OfflineModelConfig(
        // language '' lets Whisper auto-detect English/Hindi/Tamil.
        whisper: sherpa_onnx.OfflineWhisperModelConfig(
          encoder: paths.encoder,
          decoder: paths.decoder,
          language: '',
          task: 'transcribe',
        ),
        tokens: paths.tokens,
        modelType: 'whisper',
        numThreads: 2,
        debug: false,
        provider: 'cpu',
      ),
      decodingMethod: 'greedy_search',
    ),
  );

  try {
    final wave = sherpa_onnx.readWave(audioPath);

    if (wave.samples.isEmpty) {
      return '';
    }

    final stream = recognizer.createStream();
    try {
      stream.acceptWaveform(samples: wave.samples, sampleRate: wave.sampleRate);
      recognizer.decode(stream);
      return recognizer.getResult(stream).text.trim();
    } finally {
      stream.free();
    }
  } finally {
    recognizer.free();
  }
}
