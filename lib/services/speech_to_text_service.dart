import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart'
    as sherpa_onnx;

class SpeechToTextService {
  SpeechToTextService._();

  static final AudioRecorder _recorder =
      AudioRecorder();

  static sherpa_onnx.OfflineRecognizer? _recognizer;

  static bool _initialized = false;
  static bool _recording = false;

  static String? _recordingPath;

  static bool get isInitialized =>
      _initialized;

  static bool get isRecording =>
      _recording;

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
    if (_initialized &&
        _recognizer != null) {
      return;
    }

    try {
      await sherpa_onnx.initBindingsAsync();

      final encoder =
          await _copyAssetToLocal(
        'assets/speech/whisper/'
        'tiny-encoder.int8.onnx',
      );

      final decoder =
          await _copyAssetToLocal(
        'assets/speech/whisper/'
        'tiny-decoder.int8.onnx',
      );

      final tokens =
          await _copyAssetToLocal(
        'assets/speech/whisper/'
        'tiny-tokens.txt',
      );

      /*
       * IMPORTANT:
       *
       * language: ''
       *
       * means we do not force Whisper to one language.
       *
       * This is necessary for our English/Hindi/Tamil demo.
       */
      final whisper =
          sherpa_onnx.OfflineWhisperModelConfig(
        encoder: encoder,
        decoder: decoder,
        language: '',
        task: 'transcribe',
      );

      final model =
          sherpa_onnx.OfflineModelConfig(
        whisper: whisper,
        tokens: tokens,
        modelType: 'whisper',
        numThreads: 2,
        debug: false,
        provider: 'cpu',
      );

      final config =
          sherpa_onnx.OfflineRecognizerConfig(
        model: model,
        decodingMethod: 'greedy_search',
      );

      _recognizer =
          sherpa_onnx.OfflineRecognizer(
        config,
      );

      _initialized = true;

      print(
        'SpeechToTextService: Whisper ready.',
      );
    } catch (e) {
      _initialized = false;
      _recognizer = null;

      print(
        'SpeechToTextService initialization error: $e',
      );

      rethrow;
    }
  }

  static Future<void> startRecording() async {
    if (_recording) {
      return;
    }

    await initialize();

    final permission =
        await _recorder.hasPermission();

    if (!permission) {
      throw Exception(
        'Microphone permission was denied.',
      );
    }

    final directory =
        await getTemporaryDirectory();

    final path =
        '${directory.path}/farmhelper_voice.wav';

    final oldFile =
        File(path);

    if (await oldFile.exists()) {
      await oldFile.delete();
    }

    const config =
        RecordConfig(
      encoder: AudioEncoder.wav,
      sampleRate: 16000,
      numChannels: 1,
    );

    await _recorder.start(
      config,
      path: path,
    );

    _recordingPath = path;
    _recording = true;

    print(
      'SpeechToTextService: Recording started.',
    );
  }

  static Future<String> stopAndTranscribe() async {
    if (!_recording) {
      return '';
    }

    String? actualPath;

    try {
      actualPath =
          await _recorder.stop();

      _recording = false;

      actualPath ??= _recordingPath;

      _recordingPath = null;

      if (actualPath == null ||
          actualPath.isEmpty) {
        return '';
      }

      final audioFile =
          File(actualPath);

      if (!await audioFile.exists()) {
        throw Exception(
          'Recorded audio file was not found.',
        );
      }

      if (_recognizer == null) {
        await initialize();
      }

      print(
        'SpeechToTextService: Transcribing...',
      );

      final wave =
          sherpa_onnx.readWave(
        actualPath,
      );

      final stream =
          _recognizer!.createStream();

      try {
        stream.acceptWaveform(
          samples: wave.samples,
          sampleRate: wave.sampleRate,
        );

        _recognizer!.decode(stream);

        final result =
            _recognizer!.getResult(stream);

        final text =
            result.text.trim();

        print(
          'SpeechToTextService result: $text',
        );

        return text;
      } finally {
        stream.free();
      }
    } finally {
      _recording = false;
      _recordingPath = null;

      if (actualPath != null) {
        final file =
            File(actualPath);

        if (await file.exists()) {
          try {
            await file.delete();
          } catch (_) {}
        }
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

    final path =
        _recordingPath;

    _recordingPath = null;

    if (path != null) {
      final file =
          File(path);

      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
    }
  }

  static void dispose() {
    try {
      _recognizer?.free();
    } catch (_) {}

    _recognizer = null;

    _initialized = false;

    _recorder.dispose();

    _recording = false;
    _recordingPath = null;
  }
}