class SemesterModel {
  final String id;
  final String label;
  final double sgpa;
  final int totalCredits;
  final DateTime savedAt;

  const SemesterModel({
    required this.id,
    required this.label,
    required this.sgpa,
    required this.totalCredits,
    required this.savedAt,
  });

  double get contribution => sgpa * totalCredits;
}
