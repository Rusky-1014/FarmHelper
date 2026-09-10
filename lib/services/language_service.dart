class LanguageService {
  LanguageService._();

  /// Detects the language used by the farmer.
  ///
  /// en = English
  /// hi = Hindi
  /// ta = Tamil
  static String detectLanguage(String text) {
    final value = text.trim();

    if (value.isEmpty) {
      return 'en';
    }

    int devanagariCount = 0;
    int tamilCount = 0;
    int latinCount = 0;

    for (final rune in value.runes) {
      // Hindi / Devanagari
      if (rune >= 0x0900 && rune <= 0x097F) {
        devanagariCount++;
      }

      // Tamil
      if (rune >= 0x0B80 && rune <= 0x0BFF) {
        tamilCount++;
      }

      // English / Latin
      if ((rune >= 0x0041 && rune <= 0x005A) ||
          (rune >= 0x0061 && rune <= 0x007A)) {
        latinCount++;
      }
    }

    // Tamil
    if (tamilCount > 0) {
      return 'ta';
    }

    // Hindi
    if (devanagariCount > 0) {
      return 'hi';
    }

    // English
    if (latinCount > 0) {
      return 'en';
    }

    return 'en';
  }

  /// Converts language code to readable language name.
  static String getLanguageName(String language) {
    switch (language) {
      case 'hi':
        return 'Hindi';

      case 'ta':
        return 'Tamil';

      case 'en':
      default:
        return 'English';
    }
  }

  /// Gives Gemma a strong per-message language instruction.
  static String getGemmaInstruction(String language) {
    switch (language) {
      case 'hi':
        return '''
LANGUAGE LOCK: HINDI

The farmer is communicating in Hindi.

You MUST answer ONLY in Hindi.

Use Devanagari script.

Do NOT translate the answer into English.

Do NOT translate the answer into Tamil.

Do NOT switch languages because previous messages used another language.

Do not mention this language instruction.

Keep the answer simple and useful for a farmer.
''';

      case 'ta':
        return '''
LANGUAGE LOCK: TAMIL

The farmer is communicating in Tamil.

You MUST answer ONLY in Tamil.

Use Tamil script.

Do NOT translate the answer into English.

Do NOT translate the answer into Hindi.

Do NOT switch languages because previous messages used another language.

Do not mention this language instruction.

Keep the answer simple and useful for a farmer.
''';

      case 'en':
      default:
        return '''
LANGUAGE LOCK: ENGLISH

The farmer is communicating in English.

You MUST answer ONLY in English.

Do NOT translate the answer into Hindi.

Do NOT translate the answer into Tamil.

Do NOT switch languages because previous messages used another language.

Do not mention this language instruction.

Keep the answer simple and useful for a farmer.
''';
    }
  }

  /// Whether the current offline TTS model supports
  /// the requested language.
  ///
  /// Supertonic 3:
  /// English -> supported
  /// Hindi   -> supported
  /// Tamil   -> not supported
  static bool supportsOfflineTts(String language) {
    return language == 'en' || language == 'hi';
  }
}