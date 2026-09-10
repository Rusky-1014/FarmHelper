import 'package:flutter/material.dart';

import '../services/gemma_service.dart';
import '../services/language_service.dart';
import '../services/speech_to_text_service.dart';
import '../services/text_to_speech_service.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({
    super.key,
  });

  @override
  State<AiAssistantScreen> createState() =>
      _AiAssistantScreenState();
}

class _AiAssistantScreenState
    extends State<AiAssistantScreen> {
  final TextEditingController _controller =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  final List<_Message> _messages = [];

  bool _loading = true;
  bool _generating = false;
  bool _recording = false;
  bool _speaking = false;

  /*
   * This is only the currently selected/default language
   * shown in the menu.
   *
   * Actual message language is detected separately from
   * every user message.
   */
  String _language = 'en';

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  // ============================================================
  // INITIALIZATION
  // ============================================================

  Future<void> _initialize() async {
    try {
      /*
       * GemmaService now checks whether the model is already
       * installed.
       *
       * If it is already on the phone, it will NOT reinstall
       * the 555 MB model.
       */
      await GemmaService.initialize();

      /*
       * Initialize offline Whisper.
       */
      await SpeechToTextService.initialize();

      /*
       * Initialize offline Supertonic TTS.
       */
      await TextToSpeechService.initialize();

      if (!mounted) return;

      setState(() {
        _loading = false;

        _messages.add(
          const _Message(
            text:
                'Hello! I am FarmHelper AI. Ask me about your crop, plant disease, or farming problem.',
            user: false,
            language: 'en',
          ),
        );
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;

        _messages.add(
          _Message(
            text:
                'Unable to initialize the offline AI assistant.\n\n$e',
            user: false,
            language: 'en',
          ),
        );
      });
    }
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> _send(String text) async {
    text = text.trim();

    if (text.isEmpty || _generating) {
      return;
    }

    /*
     * Detect the language from THIS message.
     *
     * en = English
     * hi = Hindi
     * ta = Tamil
     */
    final detectedLanguage =
        LanguageService.detectLanguage(text);

    debugPrint(
      '======================================',
    );

    debugPrint(
      'FarmHelper detected language: '
      '$detectedLanguage',
    );

    debugPrint(
      'FarmHelper user text: $text',
    );

    /*
     * Add user's message to chat.
     */
    setState(() {
      _messages.add(
        _Message(
          text: text,
          user: true,
          language: detectedLanguage,
        ),
      );

      _generating = true;
    });

    _controller.clear();

    _scrollToBottom();

    try {
      /*
       * IMPORTANT:
       *
       * Explicitly send the detected language to Gemma.
       *
       * This prevents the previous conversation language
       * from controlling the new response.
       */
      final answer =
          await GemmaService.ask(
        text,
        language: detectedLanguage,
      );

      if (!mounted) return;

      /*
       * Add Gemma's response.
       *
       * Store the language along with the response so
       * speaker playback uses the CORRECT language.
       */
      setState(() {
        _messages.add(
          _Message(
            text: answer,
            user: false,
            language: detectedLanguage,
          ),
        );

        _generating = false;
      });

      _scrollToBottom();

      /*
       * Automatically speak the answer.
       *
       * English -> English TTS
       * Hindi   -> Hindi TTS
       * Tamil   -> skipped because current Supertonic
       *            model does not support Tamil.
       */
      await _speak(
        answer,
        language: detectedLanguage,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add(
          _Message(
            text:
                'I could not generate an answer.\n$e',
            user: false,
            language: detectedLanguage,
          ),
        );

        _generating = false;
      });

      _scrollToBottom();
    }
  }

  // ============================================================
  // START RECORDING
  // ============================================================

  Future<void> _startRecording() async {
    if (_generating || _recording) {
      return;
    }

    try {
      await SpeechToTextService.startRecording();

      if (!mounted) return;

      setState(() {
        _recording = true;
      });
    } catch (e) {
      _showError(
        e.toString(),
      );
    }
  }

  // ============================================================
  // STOP RECORDING
  // ============================================================

  Future<void> _stopRecording() async {
    if (!_recording) {
      return;
    }

    setState(() {
      _recording = false;
    });

    try {
      /*
       * Whisper converts speech into text.
       *
       * The multilingual Whisper model is configured without
       * forcing a specific language.
       */
      final text =
          await SpeechToTextService.stopAndTranscribe();

      if (text.trim().isNotEmpty) {
        /*
         * Put recognized text in the input box briefly.
         */
        _controller.text = text;

        /*
         * Send recognized text through the SAME language
         * detection + Gemma pipeline as typed text.
         */
        await _send(text);
      } else {
        _showError(
          'I could not understand the recording.',
        );
      }
    } catch (e) {
      _showError(
        e.toString(),
      );
    }
  }

  // ============================================================
  // TEXT TO SPEECH
  // ============================================================

  Future<void> _speak(
    String text, {
    required String language,
  }) async {
    try {
      /*
       * Tamil is not supported by the current Supertonic
       * model.
       *
       * Do NOT attempt to synthesize Tamil.
       */
      if (!TextToSpeechService.supportsLanguage(
        language,
      )) {
        debugPrint(
          'TTS skipped: $language is not supported.',
        );

        if (!mounted) return;

        setState(() {
          _speaking = false;
        });

        return;
      }

      if (!mounted) return;

      setState(() {
        _speaking = true;
      });

      /*
       * Send the exact response language to TTS.
       */
      final spoken =
          await TextToSpeechService.speak(
        text,
        language: language,
      );

      if (!mounted) return;

      setState(() {
        _speaking = spoken;
      });
    } catch (e) {
      debugPrint(
        'TTS error: $e',
      );

      if (!mounted) return;

      setState(() {
        _speaking = false;
      });
    }
  }

  // ============================================================
  // STOP SPEAKING
  // ============================================================

  Future<void> _stopSpeaking() async {
    await TextToSpeechService.stop();

    if (!mounted) return;

    setState(() {
      _speaking = false;
    });
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // SCROLL
  // ============================================================

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!_scrollController.hasClients) {
          return;
        }

        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration:
              const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FarmHelper AI',
        ),
        actions: [
          /*
           * Language selector.
           *
           * This is useful as a visible demo indicator,
           * but actual messages are still detected individually.
           */
          PopupMenuButton<String>(
            initialValue: _language,
            onSelected: (value) {
              setState(() {
                _language = value;
              });
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'en',
                child: Text(
                  'English',
                ),
              ),
              PopupMenuItem(
                value: 'hi',
                child: Text(
                  'हिन्दी',
                ),
              ),
              PopupMenuItem(
                value: 'ta',
                child: Text(
                  'தமிழ்',
                ),
              ),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          // ====================================================
          // CHAT
          // ====================================================

          Expanded(
            child: _loading
                ? const Center(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          'Preparing offline AI...',
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller:
                        _scrollController,
                    padding:
                        const EdgeInsets.all(16),
                    itemCount:
                        _messages.length,
                    itemBuilder:
                        (_, index) {
                      return _Bubble(
                        message:
                            _messages[index],
                      );
                    },
                  ),
          ),

          // ====================================================
          // GEMMA LOADING INDICATOR
          // ====================================================

          if (_generating)
            const Padding(
              padding:
                  EdgeInsets.only(
                bottom: 8,
              ),
              child: Text(
                'FarmHelper is thinking...',
              ),
            ),

          // ====================================================
          // RECORDING INDICATOR
          // ====================================================

          if (_recording)
            const Padding(
              padding:
                  EdgeInsets.only(
                bottom: 8,
              ),
              child: Text(
                'Listening... release the microphone when finished',
              ),
            ),

          // ====================================================
          // INPUT
          // ====================================================

          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.all(12),
              child: Row(
                children: [
                  // ============================================
                  // MICROPHONE
                  // ============================================

                  IconButton(
                    icon: Icon(
                      _recording
                          ? Icons.stop
                          : Icons.mic,
                    ),
                    onPressed:
                        _generating
                            ? null
                            : _recording
                                ? _stopRecording
                                : _startRecording,
                  ),

                  // ============================================
                  // TEXT FIELD
                  // ============================================

                  Expanded(
                    child: TextField(
                      controller:
                          _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction:
                          TextInputAction.send,
                      onSubmitted:
                          _send,
                      decoration:
                          InputDecoration(
                        hintText:
                            'Ask FarmHelper...',
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            24,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  // ============================================
                  // STOP SPEAKING
                  // ============================================

                  IconButton(
                    icon: Icon(
                      _speaking
                          ? Icons.stop_circle
                          : Icons.volume_up,
                    ),
                    onPressed:
                        _speaking
                            ? _stopSpeaking
                            : null,
                  ),

                  // ============================================
                  // SEND
                  // ============================================

                  IconButton(
                    icon:
                        const Icon(
                      Icons.send,
                    ),
                    onPressed:
                        _generating
                            ? null
                            : () => _send(
                                  _controller
                                      .text,
                                ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();

    super.dispose();
  }
}

// =================================================================
// MESSAGE MODEL
// =================================================================

class _Message {
  final String text;
  final bool user;

  /*
   * Language belonging to THIS message.
   *
   * en = English
   * hi = Hindi
   * ta = Tamil
   */
  final String language;

  const _Message({
    required this.text,
    required this.user,
    required this.language,
  });
}

// =================================================================
// CHAT BUBBLE
// =================================================================

class _Bubble extends StatelessWidget {
  final _Message message;

  const _Bubble({
    required this.message,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Align(
      alignment: message.user
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(
          maxWidth:
              MediaQuery.of(context)
                      .size
                      .width *
                  0.82,
        ),
        margin:
            const EdgeInsets.only(
          bottom: 12,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration:
            BoxDecoration(
          color: message.user
              ? Theme.of(context)
                  .colorScheme
                  .primary
              : Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
          borderRadius:
              BorderRadius.circular(
            18,
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.user
                ? Theme.of(context)
                    .colorScheme
                    .onPrimary
                : Theme.of(context)
                    .colorScheme
                    .onSurface,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}