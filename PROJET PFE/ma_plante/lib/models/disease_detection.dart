class DiseaseDetection {
  final String id;
  final String userId;
  final String userName;
  final String plantName;
  final String diseaseName;
  final double confidence;
  final DateTime timestamp;

  DiseaseDetection({
    required this.id,
    required this.userId,
    required this.userName,
    required this.plantName,
    required this.diseaseName,
    required this.confidence,
    required this.timestamp,
  });
}
