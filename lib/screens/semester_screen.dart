import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/cgpa_provider.dart';
import '../models/subject_model.dart';
import '../models/semester_model.dart';
import '../widgets/subject_tile.dart';
import '../utils/cgpa_calculator.dart';
import '../utils/constants.dart';
import '../services/ad_service.dart';
import 'result_screen.dart';

class SemesterScreen extends StatefulWidget {
  const SemesterScreen({super.key});

  @override
  State<SemesterScreen> createState() => _SemesterScreenState();
}

class _SemesterScreenState extends State<SemesterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CgpaProvider>().clearSubjects();
    });
  }

  void _showAddSubjectSheet() {
    final nameController = TextEditingController();
    int credits = 3;
    String grade = 'A';
    final grades = ['O', 'A+', 'A', 'B+', 'B', 'C', 'P', 'F'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24, right: 24, top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Add Subject', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    maxLength: 50,
                    decoration: const InputDecoration(labelText: 'Subject Name', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: credits,
                          decoration: const InputDecoration(labelText: 'Credits', border: OutlineInputBorder()),
                          items: [1, 2, 3, 4, 5, 6].map((c) => DropdownMenuItem(value: c, child: Text(c.toString()))).toList(),
                          onChanged: (v) => setState(() => credits = v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: grade,
                          decoration: const InputDecoration(labelText: 'Grade', border: OutlineInputBorder()),
                          items: grades.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                          onChanged: (v) => setState(() => grade = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a subject name')),
                        );
                        return;
                      }
                      final provider = context.read<CgpaProvider>();
                      provider.addSubject(SubjectModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text.trim(),
                        credits: credits,
                        grade: grade,
                        gradePoint: SubjectModel.gradeToPoint(grade),
                      ));
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Add Subject'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      }
    );
  }

  void _saveSemester() async {
    final provider = context.read<CgpaProvider>();
    if (provider.subjectsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one subject')));
      return;
    }

    double sgpa = provider.calculateSGPA();
    int totalCredits = provider.subjectsList.fold(0, (sum, s) => sum + s.credits);

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Semester Result'),
          content: Text('Your SGPA is ${sgpa.toStringAsFixed(2)}\nTotal Credits: $totalCredits'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _processSemesterResult(sgpa, totalCredits);
              },
              child: const Text('Save & View'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _processSemesterResult(double sgpa, int totalCredits) async {
    final provider = context.read<CgpaProvider>();
    final u = provider.selectedUniversity;

    // Add to Semester List for Overall
    provider.addSemester(SemesterModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: 'Semester ${provider.semestersList.length + 1}',
      sgpa: sgpa,
      totalCredits: totalCredits,
      savedAt: DateTime.now(),
    ));

    double percentage = u.calculatePercentage(sgpa);
    String classification = u.getClassification(percentage);
    String letterGrade = u.getLetterGrade(sgpa, u.gradingScale);

    // Save to history
    final historyEntry = {
      'type': 'Semester',
      'university_name': u.shortName,
      'cgpa': sgpa.toStringAsFixed(2),
      'percentage': percentage.toStringAsFixed(2),
      'grade': letterGrade,
      'classification': classification,
      'date': DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
    };
    await provider.saveToHistory(historyEntry);

    if (!context.mounted) return;
    AdService().onCalculationDone(context);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          title: 'SGPA Result',
          cgpa: CgpaCalculator.roundToTwoDecimals(sgpa),
          percentage: percentage,
          classification: classification,
          letterGrade: letterGrade,
          formulaUsed: 'SGPA based on Credits and Grade Points',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CgpaProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Semester SGPA Calculator')),
      body: Column(
        children: [
          Expanded(
            child: provider.subjectsList.isEmpty
                ? Center(
                    child: Text(
                      'No subjects added yet.\nTap + to add a subject.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                  )
                : ListView.builder(
                    itemCount: provider.subjectsList.length,
                    itemBuilder: (context, index) {
                      final subject = provider.subjectsList[index];
                      return SubjectTile(
                        subjectName: subject.name,
                        credits: subject.credits,
                        grade: subject.grade,
                        onDelete: () => provider.removeSubject(subject.id),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Live SGPA: ${provider.calculateSGPA().toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: AppConstants.primaryColor),
                      ),
                      Text(
                        'Total Credits: ${provider.subjectsList.fold(0, (sum, s) => sum + s.credits)}',
                        style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _saveSemester,
                    style: ElevatedButton.styleFrom(backgroundColor: AppConstants.accentColor),
                    child: const Text('Save Result', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          onPressed: _showAddSubjectSheet,
          backgroundColor: AppConstants.primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
