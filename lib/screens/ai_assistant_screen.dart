import 'package:flutter/material.dart';

import '../services/ai_context_service.dart';
import '../services/gemma_service.dart';
import '../services/language_service.dart';
import '../services/speech_to_text_service.dart';
import '../services/text_to_speech_service.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_Message> _messages = [];

  bool _loading = true;
  int? _installProgress;
  String? _initError;

  bool _generating = false;
  bool _recording = false;
  bool _transcribing = false;

  /// Index of the message currently being spoken, if any.
  int? _speakingIndex;

  bool _autoSpeak = true;

  /// 'auto' detects the language of every message from its
  /// script; otherwise answers are forced to this language.
  String _language = 'auto';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  // ============================================================
  // INITIALIZATION
  // ============================================================

  Future<void> _initialize() async {
    setState(() {
      _loading = true;
      _initError = null;
    });

    try {
      // Only Gemma is required to chat. Voice models are
      // prepared lazily the first time they are used.
      await GemmaService.initialize(
        onProgress: (p) {
          if (mounted) setState(() => _installProgress = p);
        },
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
        if (_messages.isEmpty) {
          _messages.add(const _Message(
            text: 'Hello! I am FarmHelper AI. Ask me about your crop, '
                'a plant disease, or any farming problem. '
                'You can type or tap the microphone.',
            user: false,
            language: 'en',
          ));
        }
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _initError = e.toString();
      });
    }
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> _send(String text) async {
    text = text.trim();

    if (text.isEmpty || _generating || _loading || _initError != null) {
      return;
    }

    await _stopSpeaking();

    final language =
        _language == 'auto' ? LanguageService.detectLanguage(text) : _language;

    final history = _historyForPrompt();

    setState(() {
      _messages.add(_Message(text: text, user: true, language: language));
      _messages.add(_Message(text: '', user: false, language: language));
      _generating = true;
    });

    _controller.clear();
    _scrollToBottom();

    final answerIndex = _messages.length - 1;

    try {
      await for (final partial in GemmaService.askStream(
        text,
        language: language,
        history: history,
      )) {
        if (!mounted) break;
        setState(() {
          _messages[answerIndex] =
              _messages[answerIndex].copyWith(text: partial);
        });
        _scrollToBottom(animated: false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages[answerIndex] = _messages[answerIndex].copyWith(
            text: 'I could not generate an answer. Please try again.\n'
                '(${_shortError(e)})',
            failed: true,
          );
        });
      }
    }

    if (!mounted) return;

    setState(() => _generating = false);
    _scrollToBottom();

    final answer = _messages[answerIndex];
    if (_autoSpeak && !answer.failed && answer.text.isNotEmpty) {
      await _speak(answerIndex);
    }
  }

  Future<void> _stopGenerating() async {
    await GemmaService.stopGeneration();
  }

  /// Completed question/answer pairs for the prompt.
  List<ChatTurn> _historyForPrompt() {
    final turns = <ChatTurn>[];
    for (var i = 0; i + 1 < _messages.length; i++) {
      final q = _messages[i];
      final a = _messages[i + 1];
      if (q.user && !a.user && !a.failed && a.text.isNotEmpty) {
        turns.add(ChatTurn(q.text, a.text));
      }
    }
    return turns;
  }

  void _clearChat() {
    if (_generating) return;
    _stopSpeaking();
    setState(() {
      _messages
        ..clear()
        ..add(const _Message(
          text: 'New chat started. How can I help?',
          user: false,
          language: 'en',
        ));
    });
  }

  // ============================================================
  // VOICE INPUT
  // ============================================================

  Future<void> _startRecording() async {
    if (_generating || _recording || _transcribing || _loading) {
      return;
    }

    await _stopSpeaking();

    try {
      await SpeechToTextService.startRecording();
      if (!mounted) return;
      setState(() => _recording = true);
    } catch (e) {
      _showError(_shortError(e));
    }
  }

  Future<void> _stopRecording() async {
    if (!_recording) return;

    setState(() {
      _recording = false;
      _transcribing = true;
    });

    try {
      final text = await SpeechToTextService.stopAndTranscribe();

      if (!mounted) return;
      setState(() => _transcribing = false);

      if (text.trim().isNotEmpty) {
        await _send(text);
      } else {
        _showError('I could not understand the recording. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _transcribing = false);
      _showError('Voice input failed: ${_shortError(e)}');
    }
  }

  // ============================================================
  // VOICE OUTPUT
  // ============================================================

  Future<void> _speak(int index) async {
    final message = _messages[index];

    // Supertonic has no Tamil voice; the button is hidden then.
    if (!TextToSpeechService.supportsLanguage(message.language)) {
      return;
    }

    setState(() => _speakingIndex = index);

    try {
      final started = await TextToSpeechService.speak(
        message.text,
        language: message.language,
      );

      if (!started) {
        if (mounted && _speakingIndex == index) {
          setState(() => _speakingIndex = null);
        }
        return;
      }

      // Clear the indicator when playback finishes.
      while (mounted && TextToSpeechService.isSpeaking) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }
    } catch (e) {
      debugPrint('TTS error: $e');
      _showError('Could not play voice: ${_shortError(e)}');
    }

    if (mounted && _speakingIndex == index) {
      setState(() => _speakingIndex = null);
    }
  }

  Future<void> _stopSpeaking() async {
    await TextToSpeechService.stop();
    if (mounted && _speakingIndex != null) {
      setState(() => _speakingIndex = null);
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _shortError(Object e) {
    final text = e.toString().replaceFirst('Exception: ', '');
    return text.length > 160 ? '${text.substring(0, 160)}...' : text;
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  List<String> get _suggestions {
    if (AIContextService.hasContext) {
      final disease = AIContextService.disease!;
      final crop = AIContextService.crop!;
      if (disease == 'Healthy') {
        return [
          'How do I keep my $crop plants healthy?',
          'What should I watch for this season?',
        ];
      }
      return [
        'How do I treat $disease on my $crop?',
        'How can I stop $disease from spreading?',
        'Is $disease dangerous for the fruit?',
      ];
    }
    return [
      'How often should I water mango trees?',
      'How do I prevent fungal disease on grapes?',
      'आम के पत्तों पर काले धब्बे क्यों आते हैं?',
    ];
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final busy = _generating || _recording || _transcribing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FarmHelper AI'),
        actions: [
          IconButton(
            tooltip: _autoSpeak ? 'Auto voice on' : 'Auto voice off',
            icon: Icon(_autoSpeak ? Icons.volume_up : Icons.volume_off),
            onPressed: () {
              setState(() => _autoSpeak = !_autoSpeak);
              if (!_autoSpeak) _stopSpeaking();
            },
          ),
          PopupMenuButton<String>(
            tooltip: 'Answer language',
            initialValue: _language,
            icon: const Icon(Icons.translate),
            onSelected: (value) => setState(() => _language = value),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'auto', child: Text('Auto (match my language)')),
              PopupMenuItem(value: 'en', child: Text('English')),
              PopupMenuItem(value: 'hi', child: Text('हिन्दी')),
              PopupMenuItem(value: 'ta', child: Text('தமிழ்')),
            ],
          ),
          IconButton(
            tooltip: 'New chat',
            icon: const Icon(Icons.refresh),
            onPressed: _generating || _loading ? null : _clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          if (_recording)
            const _StatusLine(
              icon: Icons.mic,
              text: 'Listening... tap stop when you finish speaking',
            ),
          if (_transcribing)
            const _StatusLine(
              icon: Icons.hearing,
              text: 'Understanding your voice...',
            ),
          if (!_loading && _initError == null) _buildInput(busy),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      final progress = _installProgress;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                progress != null && progress < 100
                    ? 'Setting up offline AI for the first time... $progress%\n'
                        'This happens only once.'
                    : 'Preparing offline AI...',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_initError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              const Text(
                'The offline AI could not start.',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Close other apps to free memory, then try again.\n\n'
                '${_shortError(_initError!)}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _initialize,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    final showSuggestions = !_messages.any((m) => m.user);

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        for (var i = 0; i < _messages.length; i++)
          _Bubble(
            message: _messages[i],
            thinking: _generating &&
                i == _messages.length - 1 &&
                _messages[i].text.isEmpty,
            speaking: _speakingIndex == i,
            canSpeak: !_messages[i].user &&
                !_messages[i].failed &&
                TextToSpeechService.supportsLanguage(_messages[i].language) &&
                _messages[i].text.isNotEmpty &&
                !(_generating && i == _messages.length - 1),
            onSpeak: () => _speakingIndex == i ? _stopSpeaking() : _speak(i),
          ),
        if (showSuggestions)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in _suggestions)
                ActionChip(
                  label: Text(s),
                  onPressed: () => _send(s),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildInput(bool busy) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Row(
          children: [
            IconButton(
              tooltip: _recording ? 'Stop recording' : 'Speak',
              icon: Icon(_recording ? Icons.stop_circle : Icons.mic),
              color: _recording ? Colors.redAccent : null,
              onPressed: _generating || _transcribing
                  ? null
                  : _recording
                      ? _stopRecording
                      : _startRecording,
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !_recording && !_transcribing,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: _send,
                decoration: InputDecoration(
                  hintText: 'Ask FarmHelper...',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            _generating
                ? IconButton(
                    tooltip: 'Stop answer',
                    icon: const Icon(Icons.stop),
                    onPressed: _stopGenerating,
                  )
                : IconButton(
                    tooltip: 'Send',
                    icon: const Icon(Icons.send),
                    onPressed: busy ? null : () => _send(_controller.text),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    GemmaService.stopGeneration();
    TextToSpeechService.stop();
    SpeechToTextService.cancelRecording();
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

  /// Language of this message: en, hi or ta.
  final String language;

  /// True when this is an error placeholder, not a real answer.
  final bool failed;

  const _Message({
    required this.text,
    required this.user,
    required this.language,
    this.failed = false,
  });

  _Message copyWith({String? text, bool? failed}) => _Message(
        text: text ?? this.text,
        user: user,
        language: language,
        failed: failed ?? this.failed,
      );
}

// =================================================================
// WIDGETS
// =================================================================

class _StatusLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _StatusLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Flexible(child: Text(text)),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final _Message message;
  final bool thinking;
  final bool speaking;
  final bool canSpeak;
  final VoidCallback onSpeak;

  const _Bubble({
    required this.message,
    required this.thinking,
    required this.speaking,
    required this.canSpeak,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textColor = message.user ? scheme.onPrimary : scheme.onSurface;

    return Align(
      alignment: message.user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        decoration: BoxDecoration(
          color: message.user
              ? scheme.primary
              : message.failed
                  ? scheme.errorContainer
                  : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (thinking)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Thinking...', style: TextStyle(color: textColor)),
                ],
              )
            else
              SelectableText(
                message.text,
                style: TextStyle(color: textColor, height: 1.4),
              ),
            if (canSpeak)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 20,
                  tooltip: speaking ? 'Stop' : 'Listen',
                  icon: Icon(
                    speaking ? Icons.stop_circle_outlined : Icons.volume_up,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                  onPressed: onSpeak,
                ),
              )
            else
              const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
