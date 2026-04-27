import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/cgpa_provider.dart';
import '../data/universities.dart';
import '../models/university_model.dart';
import '../widgets/university_selector.dart';

import '../services/ad_service.dart';
import 'result_screen.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({Key? key}) : super(key: key);

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _cgpaController = TextEditingController();

  void _calculate() async {
    FocusScope.of(context).unfocus();
    final provider = context.read<CgpaProvider>();
    final u = provider.selectedUniversity;

    double? cgpaInput = double.tryParse(_cgpaController.text);
    if (cgpaInput == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid numeric CGPA')));
      return;
    }

    double maxScale = u.id == 'mumbai_uni' ? 10.0 : u.gradingScale.toDouble();
    if (cgpaInput > maxScale || cgpaInput < 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a valid CGPA between 0 and ${maxScale.toInt()}')));
      return;
    }

    provider.calculateFromCgpa(cgpaInput);

    double percentage = provider.currentPercentage;
    String classification = u.getClassification(percentage);
    String letterGrade = u.getLetterGrade(cgpaInput, u.gradingScale);

    // Save to history
    final historyEntry = {
      'type': 'Converter',
      'university_name': u.shortName,
      'cgpa': cgpaInput.toStringAsFixed(2),
      'percentage': percentage.toStringAsFixed(2),
      'grade': letterGrade,
      'classification': classification,
      'date': DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
    };
    provider.saveToHistory(historyEntry);

    AdService().onCalculationDone(context);

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            title: 'Conversion Result',
            cgpa: cgpaInput,
            percentage: percentage,
            classification: classification,
            letterGrade: letterGrade,
            formulaUsed: u.formulaDescription,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CgpaProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('CGPA to Percentage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showFormulaInfo(context, provider.selectedUniversity);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Select University', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            UniversitySelector(
              universities: universitiesData,
              selectedUniversity: provider.selectedUniversity,
              onChanged: (u) => provider.selectUniversity(u),
            ),
            const SizedBox(height: 24),
            Text('Enter your CGPA', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _cgpaController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    LengthLimitingTextInputFormatter(5),
                  ],
                  decoration: InputDecoration(
                    hintText: 'e.g. 8.5',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    suffixText: '/ ${provider.selectedUniversity.id == 'mumbai_uni' ? 10 : provider.selectedUniversity.gradingScale}',
                  ),
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6F00),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Calculate Now',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFormulaInfo(BuildContext context, UniversityModel u) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Formula Information', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('University:', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            Text(u.name),
            const SizedBox(height: 16),
            Text('Formula Used:', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
              child: Text(u.formulaDescription, style: GoogleFonts.ibmPlexMono()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
