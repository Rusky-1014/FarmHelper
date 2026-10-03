import 'package:flutter_test/flutter_test.dart';

import 'package:plant_disease_app/services/ai_context_service.dart';
import 'package:plant_disease_app/services/labels.dart';
import 'package:plant_disease_app/services/language_service.dart';
import 'package:plant_disease_app/services/medicine_service.dart';
import 'package:plant_disease_app/services/prediction_service.dart';
import 'package:plant_disease_app/services/text_to_speech_service.dart';

void main() {
  group('LanguageService', () {
    test('detects language from script', () {
      expect(LanguageService.detectLanguage('How to treat mildew?'), 'en');
      expect(LanguageService.detectLanguage('आम के पत्ते'), 'hi');
      expect(LanguageService.detectLanguage('மாம்பழ இலை'), 'ta');
      expect(LanguageService.detectLanguage('  '), 'en');
    });

    test('Tamil has no offline voice', () {
      expect(LanguageService.supportsOfflineTts('en'), isTrue);
      expect(LanguageService.supportsOfflineTts('hi'), isTrue);
      expect(LanguageService.supportsOfflineTts('ta'), isFalse);
    });
  });

  group('PredictionService', () {
    test('argmax and confidence', () {
      final values = [0.1, 0.7, 0.2];
      expect(PredictionService.argmax(values), 1);
      expect(PredictionService.confidence(values), 0.7);
    });
  });

  test('every label has a treatment entry', () {
    for (final entry in cropLabels.entries) {
      for (final disease in entry.value) {
        final medicine = MedicineService.getMedicine(entry.key, disease);
        expect(medicine.name, isNot('Consult local agronomist'),
            reason: '${entry.key}/$disease');
      }
    }
  });

  test('AI context includes the scan and treatment', () {
    AIContextService.setDiseaseContext(
      cropName: 'mango',
      diseaseName: 'Anthracnose',
      diseaseConfidence: 0.91,
    );
    final context = AIContextService.buildContext();
    expect(context, contains('Anthracnose'));
    expect(context, contains('91%'));
    expect(context, contains('Copper Oxychloride'));
    AIContextService.clear();
    expect(AIContextService.buildContext(), isEmpty);
  });

  test('speech text has markdown removed and is capped', () {
    expect(
      TextToSpeechService.cleanForSpeech('**Spray** neem oil.\n- Remove leaves'),
      'Spray neem oil. Remove leaves',
    );
    final long = List.filled(200, 'Water the plant.').join(' ');
    expect(TextToSpeechService.cleanForSpeech(long).length, lessThanOrEqualTo(600));
  });
}
