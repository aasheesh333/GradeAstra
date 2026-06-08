import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../providers/cgpa_provider.dart';
import '../models/semester_model.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import '../utils/cgpa_calculator.dart';
import '../services/ad_service.dart';
import 'result_screen.dart';

class OverallScreen extends StatefulWidget {
  const OverallScreen({super.key});

  @override
  State<OverallScreen> createState() => _OverallScreenState();
}

class _OverallScreenState extends State<OverallScreen> {

  void _showAddSemesterDialog() {
    final sgpaController = TextEditingController();
    final creditsController = TextEditingController();
    final provider = context.read<CgpaProvider>();
    final maxScale = provider.selectedUniversity.gradingScale;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Semester'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: sgpaController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                LengthLimitingTextInputFormatter(5),
              ],
              decoration: InputDecoration(
                labelText: 'SGPA (0-$maxScale)',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: creditsController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              decoration: const InputDecoration(
                labelText: 'Total Credits',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              double? sgpa = double.tryParse(sgpaController.text);
              int? credits = int.tryParse(creditsController.text);

              if (sgpa == null || credits == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter valid SGPA and credits')),
                );
                return;
              }
              if (sgpa < 0 || sgpa > maxScale) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('SGPA must be between 0 and $maxScale')),
                );
                return;
              }
              if (credits <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Credits must be greater than 0')),
                );
                return;
              }

              provider.addSemester(SemesterModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                label: 'Semester ${provider.semestersList.length + 1}',
                sgpa: sgpa,
                totalCredits: credits,
                savedAt: DateTime.now(),
              ));
              Navigator.pop(context);
              AdService().onCalculationDone(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _viewFinalResult() {
    final provider = context.read<CgpaProvider>();
    if (provider.semestersList.isEmpty) return;

    double cgpa = provider.calculateOverallCGPA();
    final u = provider.selectedUniversity;
    double percentage = u.calculatePercentage(cgpa);
    String classification = u.getClassification(percentage);
    String letterGrade = u.getLetterGrade(cgpa, u.gradingScale);

    // Save to history
    final historyEntry = {
      'type': 'Overall',
      'university_name': u.shortName,
      'cgpa': cgpa.toStringAsFixed(2),
      'percentage': percentage.toStringAsFixed(2),
      'grade': letterGrade,
      'classification': classification,
      'date': DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
    };
    provider.saveToHistory(historyEntry);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          title: 'Overall CGPA Result',
          cgpa: CgpaCalculator.roundToTwoDecimals(cgpa),
          percentage: percentage,
          classification: classification,
          letterGrade: letterGrade,
          formulaUsed: 'Weighted average of all semesters',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CgpaProvider>();
    final semesters = provider.semestersList;

    return Scaffold(
      appBar: AppBar(title: const Text('Overall CGPA Calculator')),
      body: Column(
        children: [
          if (semesters.isNotEmpty)
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text('S${value.toInt()}', style: const TextStyle(fontSize: 10)),
                        interval: 1,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 1,
                  maxX: semesters.length.toDouble(),
                  minY: 0,
                  maxY: provider.selectedUniversity.gradingScale.toDouble(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: semesters.asMap().entries.map((e) => FlSpot(e.key + 1.0, e.value.sgpa)).toList(),
                      isCurved: true,
                      color: const Color(0xFF1565C0),
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF1565C0).withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: semesters.isEmpty
                ? Center(
                    child: Text('No semesters added yet.', style: GoogleFonts.inter(color: Colors.grey)),
                  )
                : ListView.builder(
                    itemCount: semesters.length,
                    itemBuilder: (context, index) {
                      final sem = semesters[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(sem.label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        subtitle: Text('Credits: ${sem.totalCredits}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(sem.sgpa.toStringAsFixed(2), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                provider.removeSemester(sem.id);
                                AdService().onCalculationDone(context);
                              },
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
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
                        'Overall CGPA: ${provider.calculateOverallCGPA().toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1565C0)),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: semesters.isNotEmpty ? _viewFinalResult : null,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6F00)),
                    child: const Text('View Result', style: TextStyle(color: Colors.white)),
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
          onPressed: _showAddSemesterDialog,
          backgroundColor: const Color(0xFF1565C0),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
