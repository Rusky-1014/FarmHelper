import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

import 'ai_context_service.dart';
import 'language_service.dart';

/// One previous exchange, replayed to Gemma as short context.
class ChatTurn {
  final String question;
  final String answer;

  const ChatTurn(this.question, this.answer);
}

/// Offline Gemma 3 1B assistant.
///
/// WHY EVERY QUESTION STARTS A FRESH SESSION:
/// The model has a fixed 2048-token context window. The old
/// code kept appending every prompt and answer to one native
/// session, and flutter_gemma's non-streaming call never trims
/// it, so after a few questions the window was full and Gemma
/// silently stopped answering. Now the native session is
/// cleared before each question and only a short, truncated
/// summary of the last exchanges is sent along, so the prompt
/// size stays bounded no matter how long the chat gets.
class GemmaService {
  GemmaService._();

  static const _modelAsset = 'assets/models/gemma3-1b-it-int4.task';

  static const _maxTokens = 2048;
  static const _maxOutputTokens = 512;

  /// How many previous exchanges are replayed, and how many
  /// characters of each are kept.
  static const _historyTurns = 2;
  static const _historyChars = 240;

  static const _systemInstruction = '''
You are FarmHelper, an offline assistant for farmers, running on the farmer's phone.
Help with crop diseases, plant health, pests, irrigation, soil, fertilizer and general farming.
Rules:
- Use simple words a farmer understands.
- Keep answers short: 3 to 6 short points or a few sentences.
- Give practical steps the farmer can do today.
- If a leaf scan result is given, use it, but say the scan can be wrong.
- Only give a chemical dosage if the app's recommended treatment lists it. Otherwise tell the farmer to follow the product label or the local agriculture office.
- Never claim to use the internet.''';

  static InferenceModel? _model;
  static InferenceChat? _chat;

  static Future<void>? _initFuture;

  static bool _busy = false;

  static bool get isInitialized => _chat != null;

  static bool get isBusy => _busy;

  /// Installs (first launch only) and loads the model.
  ///
  /// Safe to call many times; concurrent callers share the
  /// same initialization.
  static Future<void> initialize({
    void Function(int progress)? onProgress,
  }) {
    if (_chat != null) {
      return Future.value();
    }

    return _initFuture ??= _initialize(onProgress).catchError((Object e) {
      _initFuture = null;
      throw e;
    });
  }

  static Future<void> _initialize(
    void Function(int progress)? onProgress,
  ) async {
    debugPrint('GemmaService: preparing model...');

    // install() skips the copy when the model is already on
    // the device, and always marks it as the active model.
    // (The old code skipped install() when the model existed,
    // which left no active model after an app restart.)
    await FlutterGemma.installModel(
      modelType: ModelType.gemmaIt,
      fileType: ModelFileType.task,
    ).fromAsset(_modelAsset).withProgress((progress) {
      onProgress?.call(progress);
    }).install();

    // GPU is much faster, but not every phone supports it.
    // Creating the session is where an unsupported GPU fails.
    InferenceModel? model;
    try {
      model = await FlutterGemma.getActiveModel(
        maxTokens: _maxTokens,
        preferredBackend: PreferredBackend.gpu,
      );
      _chat = await _createChat(model);
      debugPrint('GemmaService: using GPU.');
    } catch (e) {
      debugPrint('GemmaService: GPU unavailable ($e), using CPU.');
      try {
        await model?.close();
      } catch (_) {}
      model = await FlutterGemma.getActiveModel(
        maxTokens: _maxTokens,
        preferredBackend: PreferredBackend.cpu,
      );
      _chat = await _createChat(model);
    }
    _model = model;

    debugPrint('GemmaService: ready.');
  }

  static Future<InferenceChat> _createChat(InferenceModel model) {
    return model.createChat(
      temperature: 0.5,
      randomSeed: 42,
      topK: 40,
      topP: 0.95,
      maxOutputTokens: _maxOutputTokens,
      systemInstruction: _systemInstruction,
    );
  }

  /// Asks a question and streams the answer as it is
  /// generated. Each event is the full answer so far.
  static Stream<String> askStream(
    String question, {
    String? language,
    List<ChatTurn> history = const [],
  }) async* {
    final cleanQuestion = question.trim();
    if (cleanQuestion.isEmpty) {
      return;
    }

    await initialize();

    if (_busy) {
      throw Exception('FarmHelper AI is still answering. Please wait.');
    }
    _busy = true;

    final lang = language ?? LanguageService.detectLanguage(cleanQuestion);
    final buffer = StringBuffer();

    try {
      // Start from an empty native context every time.
      await _chat!.clearHistory();

      await _chat!.addQueryChunk(
        Message.text(
          text: _buildPrompt(cleanQuestion, lang, history),
          isUser: true,
        ),
      );

      await for (final response in _chat!.generateChatResponseAsync()) {
        if (response is TextResponse && response.token.isNotEmpty) {
          buffer.write(response.token);
          yield _cleanAnswer(buffer.toString());
        }
      }

      if (_cleanAnswer(buffer.toString()).isEmpty) {
        yield LanguageService.emptyAnswerMessage(lang);
      }
    } catch (e, st) {
      debugPrint('GemmaService: generation error: $e\n$st');
      // Make sure the next question gets a healthy session.
      await _recoverSession();
      rethrow;
    } finally {
      _busy = false;
    }
  }

  /// Non-streaming convenience wrapper.
  static Future<String> ask(
    String question, {
    String? language,
    List<ChatTurn> history = const [],
  }) async {
    var answer = '';
    await for (final partial
        in askStream(question, language: language, history: history)) {
      answer = partial;
    }
    return answer;
  }

  /// Stops the answer currently being generated.
  static Future<void> stopGeneration() async {
    if (!_busy) return;
    try {
      await _chat?.stopGeneration();
    } catch (e) {
      debugPrint('GemmaService: stop warning: $e');
    }
  }

  static Future<void> resetConversation() async {
    await _recoverSession();
  }

  /// Releases the in-memory model. The installed model file
  /// stays on the phone.
  static Future<void> dispose() async {
    try {
      await _chat?.close();
    } catch (_) {}
    try {
      await _model?.close();
    } catch (_) {}
    _chat = null;
    _model = null;
    _initFuture = null;
  }

  static Future<void> _recoverSession() async {
    final model = _model;
    if (model == null) return;
    try {
      await _chat?.close();
    } catch (_) {}
    try {
      _chat = await _createChat(model);
    } catch (e) {
      debugPrint('GemmaService: could not recreate chat: $e');
      _chat = null;
      _initFuture = null;
    }
  }

  static String _buildPrompt(
    String question,
    String lang,
    List<ChatTurn> history,
  ) {
    final prompt = StringBuffer();

    final context = AIContextService.buildContext();
    if (context.isNotEmpty) {
      prompt
        ..writeln(context)
        ..writeln();
    }

    final recent = history.length > _historyTurns
        ? history.sublist(history.length - _historyTurns)
        : history;
    if (recent.isNotEmpty) {
      prompt.writeln('Earlier in this chat:');
      for (final turn in recent) {
        prompt
          ..writeln('Farmer: ${_truncate(turn.question)}')
          ..writeln('FarmHelper: ${_truncate(turn.answer)}');
      }
      prompt.writeln();
    }

    prompt
      ..writeln('Farmer\'s question: $question')
      ..writeln()
      ..write(LanguageService.getGemmaInstruction(lang));

    return prompt.toString();
  }

  static String _truncate(String text) {
    final value = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return value.length <= _historyChars
        ? value
        : '${value.substring(0, _historyChars)}...';
  }

  /// Strips Gemma control tokens that sometimes leak into text.
  static String _cleanAnswer(String text) {
    return text
        .replaceAll(RegExp(r'<(start|end)_of_turn>(model|user)?'), '')
        .replaceAll('<eos>', '')
        .trim();
  }
}
