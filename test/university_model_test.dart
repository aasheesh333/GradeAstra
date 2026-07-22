import 'package:flutter_test/flutter_test.dart';
import 'package:cgpa_calculator/models/university_model.dart';
import 'package:cgpa_calculator/data/universities.dart';

void main() {
  group('UniversityModel percentage conversion', () {
    test('generic university cgpa to percentage', () {
      final uni = UniversityModel(
        id: 'generic_test',
        name: 'Generic Test',
        shortName: 'Generic',
        state: 'Test',
        gradingScale: 10,
        formulaDescription: 'percentage = cgpa * 10',
        calculatePercentageLogic: (cgpa) => cgpa * 10,
        calculateCgpaFromPercentageLogic: (percentage) => percentage / 10,
      );

      expect(uni.calculatePercentage(8.5), 85.0);
    });

    test('generic university reverse conversion', () {
      final uni = UniversityModel(
        id: 'generic_test',
        name: 'Generic Test',
        shortName: 'Generic',
        state: 'Test',
        gradingScale: 10,
        formulaDescription: 'percentage = cgpa * 10',
        calculatePercentageLogic: (cgpa) => cgpa * 10,
        calculateCgpaFromPercentageLogic: (percentage) => percentage / 10,
      );

      expect(uni.calculateCgpaFromPercentage(85.0), 8.5);
    });
  });

  group('All universities support reverse conversion', () {
    test('every entry has both forward and reverse logic', () {
      for (final u in universitiesData) {
        expect(u.supportsReverseConversion, true, reason: '${u.name} is missing reverse conversion');
      }
    });
  });
}
