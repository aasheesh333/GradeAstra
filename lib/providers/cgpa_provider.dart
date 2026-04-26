import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/university_model.dart';
import '../models/subject_model.dart';
import '../models/semester_model.dart';
import '../data/universities.dart';

class CgpaProvider with ChangeNotifier {
  UniversityModel _selectedUniversity = universitiesData.firstWhere((u) => u.id == 'generic', orElse: () => universitiesData.last);
  double _currentCgpa = 0.0;
  double _currentPercentage = 0.0;

  List<SubjectModel> _subjectsList = [];
  List<SemesterModel> _semestersList = [];
  List<Map<String, dynamic>> _calculationHistory = [];

  UniversityModel get selectedUniversity => _selectedUniversity;
  double get currentCgpa => _currentCgpa;
  double get currentPercentage => _currentPercentage;
  List<SubjectModel> get subjectsList => _subjectsList;
  List<SemesterModel> get semestersList => _semestersList;
  List<Map<String, dynamic>> get calculationHistory => _calculationHistory;

  CgpaProvider() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load default university
    String? defaultUniId = prefs.getString('default_university');
    if (defaultUniId != null) {
      try {
        _selectedUniversity = universitiesData.firstWhere((u) => u.id == defaultUniId);
      } catch (_) {}
    }
    // Note: loadHistory is explicitly called from HomeScreen's initState
  }

  void selectUniversity(UniversityModel u) async {
    _selectedUniversity = u;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('default_university', u.id);
  }

  void calculateFromCgpa(double cgpa) {
    _currentCgpa = cgpa;
    _currentPercentage = _selectedUniversity.calculatePercentage(cgpa);
    notifyListeners();
  }

  void addSubject(SubjectModel s) {
    _subjectsList.add(s);
    notifyListeners();
  }

  void removeSubject(String id) {
    _subjectsList.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void clearSubjects() {
    _subjectsList.clear();
    notifyListeners();
  }

  double calculateSGPA() {
    if (_subjectsList.isEmpty) return 0.0;

    double totalWeightedPoints = 0;
    int totalCredits = 0;

    for (var subject in _subjectsList) {
      totalWeightedPoints += subject.weightedPoints;
      totalCredits += subject.credits;
    }

    if (totalCredits == 0) return 0.0;
    return totalWeightedPoints / totalCredits;
  }

  void addSemester(SemesterModel s) {
    _semestersList.add(s);
    notifyListeners();
  }

  void removeSemester(String id) {
    _semestersList.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  double calculateOverallCGPA() {
    if (_semestersList.isEmpty) return 0.0;

    double totalContributions = 0;
    int totalCredits = 0;

    for (var semester in _semestersList) {
      totalContributions += semester.contribution;
      totalCredits += semester.totalCredits;
    }

    if (totalCredits == 0) return 0.0;
    return totalContributions / totalCredits;
  }

  Future<void> saveToHistory(Map<String, dynamic> entry) async {
    _calculationHistory.insert(0, entry);
    notifyListeners();
    await _persistHistory();
  }

  Future<void> removeHistoryEntry(int index) async {
    _calculationHistory.removeAt(index);
    notifyListeners();
    await _persistHistory();
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    String? historyStr = prefs.getString('calculation_history');
    if (historyStr != null) {
      try {
        List<dynamic> decoded = json.decode(historyStr);
        _calculationHistory = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        notifyListeners();
      } catch (e) {
        await prefs.remove('calculation_history');
        _calculationHistory = [];
        notifyListeners();
      }
    }
  }

  Future<void> clearHistory() async {
    _calculationHistory.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('calculation_history');
  }

  Future<void> _persistHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calculation_history', json.encode(_calculationHistory));
  }
}
