class AIContextService {
  static String? crop;
  static String? disease;
  static double? confidence;

  static void setDiseaseContext({
    required String cropName,
    required String diseaseName,
    required double diseaseConfidence,
  }) {
    crop = cropName;
    disease = diseaseName;
    confidence = diseaseConfidence;
  }

  static void clear() {
    crop = null;
    disease = null;
    confidence = null;
  }

  static String buildContext() {
    if (crop == null || disease == null) {
      return '';
    }

    final percentage =
        ((confidence ?? 0) * 100).toStringAsFixed(1);

    return '''
Current disease detection context:

Crop: $crop
Detected disease: $disease
Detection confidence: $percentage%

Use this context when answering the farmer.
Do not present the detection as absolute certainty.
''';
  }
}