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

  /// Per-message language instruction, placed at the end of
  /// the prompt where the small model follows it best.
  static String getGemmaInstruction(String language) {
    switch (language) {
      case 'hi':
        return 'Answer only in Hindi, using Devanagari script. '
            'Do not use English sentences.';

      case 'ta':
        return 'Answer only in Tamil, using Tamil script. '
            'Do not use English sentences.';

      case 'en':
      default:
        return 'Answer only in English.';
    }
  }

  /// Shown when the model produced no text at all.
  static String emptyAnswerMessage(String language) {
    switch (language) {
      case 'hi':
        return 'माफ़ कीजिए, मैं इसका उत्तर नहीं दे पाया। कृपया अपना प्रश्न दोबारा, थोड़े अलग शब्दों में पूछें।';
      case 'ta':
        return 'மன்னிக்கவும், என்னால் பதில் தர முடியவில்லை. உங்கள் கேள்வியை வேறு வார்த்தைகளில் மீண்டும் கேளுங்கள்.';
      case 'en':
      default:
        return 'Sorry, I could not answer that. Please ask again in different words.';
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