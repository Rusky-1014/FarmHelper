import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

import 'ai_context_service.dart';
import 'language_service.dart';

class GemmaService {
  static InferenceModel? _model;
  static InferenceChat? _chat;

  static bool _initialized = false;
  static bool _initializing = false;

  static bool get isInitialized => _initialized;

  /// Initializes Gemma.
  ///
  /// IMPORTANT:
  /// FlutterGemma.initialize() is handled by main.dart.
  ///
  /// This method:
  /// 1. Checks whether the Gemma model is already installed.
  /// 2. Installs it ONLY if it is missing.
  /// 3. Loads the installed model.
  ///
  /// Therefore, once the model is installed on the phone,
  /// this method does NOT copy the 555 MB model again.
  static Future<void> initialize({
    void Function(int progress)? onProgress,
  }) async {
    if (_initialized && _chat != null) {
      debugPrint(
        'GemmaService: Already initialized.',
      );
      return;
    }

    if (_initializing) {
      debugPrint(
        'GemmaService: Initialization already in progress.',
      );
      return;
    }

    _initializing = true;

    try {
      debugPrint(
        '======================================',
      );
      debugPrint(
        '        FARMHELPER GEMMA START        ',
      );
      debugPrint(
        '======================================',
      );

      const modelId = 'gemma3-1b-it-int4';

      /*
       * CHECK EXISTING MODEL
       *
       * This prevents the 555 MB model from being
       * copied again on every initialization.
       */
      debugPrint(
        'Checking installed Gemma model...',
      );

      final alreadyInstalled =
          await FlutterGemma.isModelInstalled(
        modelId,
      );

      if (alreadyInstalled) {
        debugPrint(
          'Gemma model already installed.',
        );

        debugPrint(
          'Skipping Gemma installation.',
        );
      } else {
        debugPrint(
          'Gemma model not installed.',
        );

        debugPrint(
          'Installing Gemma model from asset...',
        );

        await FlutterGemma.installModel(
          modelType: ModelType.gemmaIt,
          fileType: ModelFileType.task,
        )
            .fromAsset(
              'assets/models/gemma3-1b-it-int4.task',
            )
            .withProgress((progress) {
              debugPrint(
                'Gemma installation: $progress%',
              );

              onProgress?.call(progress);
            })
            .install();

        debugPrint(
          'Gemma model installation completed.',
        );
      }

      /*
       * LOAD EXISTING MODEL
       */
      debugPrint(
        'Loading active Gemma model...',
      );

      _model =
          await FlutterGemma.getActiveModel(
        maxTokens: 2048,
        preferredBackend: PreferredBackend.gpu,
      );

      debugPrint(
        'Active Gemma model loaded.',
      );

      /*
       * CREATE CHAT
       *
       * The system instruction is intentionally
       * language-neutral.
       *
       * The actual language is locked PER MESSAGE
       * inside ask().
       */
      _chat = await _model!.createChat(
        temperature: 0.4,
        randomSeed: 42,
        topK: 40,
        maxOutputTokens: 512,
        systemInstruction: '''
You are FarmHelper, an offline agricultural AI assistant.

Your purpose is to help farmers understand:

- crop diseases
- plant health
- disease prevention
- irrigation
- crop care
- basic agricultural practices
- general farming questions

Always follow the language lock supplied with each farmer message.

Use simple, practical language.

If disease detection context is provided, use it.

Disease detection is not absolute certainty.

Never claim internet access.

Never claim that you consulted an online source.

Never invent pesticide or chemical dosages.

If asked for pesticide dosage, advise the farmer to
follow the product label and local agricultural guidance.

Do not pretend to be a certified agricultural officer.

Give actionable advice whenever appropriate.

You are running completely offline on the farmer's device.
''',
      );

      _initialized = true;

      debugPrint(
        '======================================',
      );
      debugPrint(
        '          GEMMA READY                 ',
      );
      debugPrint(
        '======================================',
      );
    } catch (e, stackTrace) {
      _initialized = false;
      _model = null;
      _chat = null;

      debugPrint(
        'GEMMA INITIALIZATION ERROR: $e',
      );

      debugPrint(
        stackTrace.toString(),
      );

      rethrow;
    } finally {
      _initializing = false;
    }
  }

  /// Sends a farmer question to Gemma.
  ///
  /// If language is supplied, it is used directly.
  /// Otherwise the language is detected from the question.
  static Future<String> ask(
    String question, {
    String? language,
  }) async {
    if (!_initialized || _chat == null) {
      throw Exception(
        'FarmHelper AI has not been initialized yet.',
      );
    }

    final cleanQuestion =
        question.trim();

    if (cleanQuestion.isEmpty) {
      return '';
    }

    /*
     * Detect the language of THIS message.
     *
     * This is extremely important because the
     * conversation can contain multiple languages.
     */
    final detectedLanguage =
        language ??
            LanguageService.detectLanguage(
              cleanQuestion,
            );

    final languageInstruction =
        LanguageService.getGemmaInstruction(
      detectedLanguage,
    );

    /*
     * Get current disease detection information.
     */
    final diseaseContext =
        AIContextService.buildContext();

    /*
     * Construct the complete prompt.
     */
    final prompt = '''
$languageInstruction

IMPORTANT:
Answer the farmer's current question directly.

Do not discuss the language instruction.

CURRENT FARMER LANGUAGE:
${LanguageService.getLanguageName(detectedLanguage)}

${diseaseContext.isNotEmpty ? diseaseContext : ''}

FARMER'S CURRENT QUESTION:
$cleanQuestion
''';

    debugPrint(
      '======================================',
    );

    debugPrint(
      'Gemma language: $detectedLanguage',
    );

    debugPrint(
      'Gemma question: $cleanQuestion',
    );

    /*
     * Send the language-locked message.
     */
    await _chat!.addQueryChunk(
      Message.text(
        text: prompt,
        isUser: true,
      ),
    );

    /*
     * Generate response.
     */
    final response =
        await _chat!.generateChatResponse();

    /*
     * TextResponse.token contains the actual
     * generated text.
     */
    if (response is TextResponse) {
      final text =
          response.token.trim();

      debugPrint(
        'Gemma response [$detectedLanguage]: $text',
      );

      return text;
    }

    debugPrint(
      'Unexpected Gemma response type: '
      '${response.runtimeType}',
    );

    return response.toString();
  }

  /// Resets the conversation without uninstalling
  /// the Gemma model.
  static Future<void> resetConversation() async {
    if (_model == null) {
      return;
    }

    try {
      await _chat?.session.close();
    } catch (e) {
      debugPrint(
        'Gemma chat close warning: $e',
      );
    }

    _chat = await _model!.createChat(
      temperature: 0.4,
      randomSeed: 42,
      topK: 40,
      maxOutputTokens: 512,
      systemInstruction: '''
You are FarmHelper, an offline agricultural AI assistant.

Help farmers with:

- crop diseases
- plant health
- disease prevention
- irrigation
- crop care
- general agricultural questions

Always follow the language lock provided with each
farmer message.

Use simple, practical language.

Use disease detection context when provided.

Never claim internet access.

Never claim that you consulted online sources.

Never invent pesticide or chemical dosages.

Give practical agricultural advice.

You are running completely offline.
''',
    );

    debugPrint(
      'Gemma conversation reset.',
    );
  }

  /// Releases the in-memory Gemma runtime.
  ///
  /// IMPORTANT:
  /// This does NOT uninstall the model from the phone.
  static Future<void> dispose() async {
    try {
      await _chat?.session.close();
    } catch (_) {}

    _chat = null;

    try {
      await _model?.close();
    } catch (_) {}

    _model = null;
    _initialized = false;

    debugPrint(
      'Gemma runtime resources released.',
    );

    debugPrint(
      'Installed Gemma model remains on device.',
    );
  }
}