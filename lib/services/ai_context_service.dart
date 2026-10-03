import 'medicine_service.dart';

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

  static bool get hasContext => crop != null && disease != null;

  static String buildContext() {
    if (crop == null || disease == null) {
      return '';
    }

    final percentage = ((confidence ?? 0) * 100).toStringAsFixed(0);
    final medicine = MedicineService.getMedicine(crop!, disease!);

    // The treatment shown on the result screen is passed in so
    // the assistant repeats the app's advice instead of
    // inventing different chemicals or dosages.
    return '''
Latest leaf scan in the app:
Crop: $crop
Detected: $disease ($percentage% confidence, may be wrong)
App's recommended treatment: ${medicine.name}; dosage ${medicine.dosage}; ${medicine.frequency}. ${medicine.notes}''';
  }
}
