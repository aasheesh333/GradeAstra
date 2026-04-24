class CgpaCalculator {
  static double validateCgpa(double cgpa, int scale) {
    if (cgpa < 0) return 0.0;
    if (cgpa > scale) return scale.toDouble();
    return cgpa;
  }

  static double roundToTwoDecimals(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  static String getGradeClassification(double percentage) {
    if (percentage >= 75) return "Distinction";
    if (percentage >= 60) return "First Class";
    if (percentage >= 50) return "Second Class";
    if (percentage >= 40) return "Pass Class";
    return "Fail";
  }

  static String getLetterGrade(double cgpa, int scale) {
    if (scale == 10) {
      if (cgpa >= 9.5) return "O";
      if (cgpa >= 8.5) return "A+";
      if (cgpa >= 7.5) return "A";
      if (cgpa >= 6.5) return "B+";
      if (cgpa >= 5.5) return "B";
      if (cgpa >= 4.5) return "C";
      if (cgpa >= 4.0) return "P";
      return "F";
    } else if (scale == 4) {
      if (cgpa >= 3.8) return "O";
      if (cgpa >= 3.5) return "A+";
      if (cgpa >= 3.0) return "A";
      if (cgpa >= 2.5) return "B+";
      if (cgpa >= 2.0) return "B";
      if (cgpa >= 1.5) return "C";
      if (cgpa >= 1.0) return "P";
      return "F";
    } else if (scale == 7) {
      if (cgpa >= 6.5) return "O";
      if (cgpa >= 6.0) return "A+";
      if (cgpa >= 5.5) return "A";
      if (cgpa >= 5.0) return "B+";
      if (cgpa >= 4.5) return "B";
      if (cgpa >= 4.0) return "C";
      if (cgpa >= 3.5) return "P";
      return "F";
    }
    return "F"; // Default
  }
}
