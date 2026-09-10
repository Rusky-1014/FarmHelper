class ScanRecord {
  final String id;
  final String crop;
  final String disease;
  final double confidence;
  final String imagePath;
  final DateTime timestamp;

  const ScanRecord({
    required this.id,
    required this.crop,
    required this.disease,
    required this.confidence,
    required this.imagePath,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'crop': crop,
        'disease': disease,
        'confidence': confidence,
        'imagePath': imagePath,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ScanRecord.fromJson(Map<String, dynamic> json) => ScanRecord(
        id: json['id'] as String,
        crop: json['crop'] as String,
        disease: json['disease'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        imagePath: json['imagePath'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}