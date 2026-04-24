class SubjectModel {
  final String id;
  final String name;
  final int credits;
  final String grade;
  final double gradePoint;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.credits,
    required this.grade,
    required this.gradePoint,
  });

  double get weightedPoints => credits * gradePoint;

  static double gradeToPoint(String grade) {
    switch (grade.toUpperCase()) {
      case 'O':
        return 10.0;
      case 'A+':
        return 9.0;
      case 'A':
        return 8.0;
      case 'B+':
        return 7.0;
      case 'B':
        return 6.0;
      case 'C':
        return 5.0;
      case 'P':
        return 4.0;
      case 'F':
      default:
        return 0.0;
    }
  }
}
