import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/cgpa_provider.dart';
import '../utils/constants.dart';
import '../services/ad_service.dart';
import 'result_screen.dart';

class QuickConvertScreen extends StatefulWidget {
  const QuickConvertScreen({super.key});

  @override
  State<QuickConvertScreen> createState() => _QuickConvertScreenState();
}

class _QuickConvertScreenState extends State<QuickConvertScreen> {
  final TextEditingController _cgpaController = TextEditingController();

  @override
  void dispose() {
    _cgpaController.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    FocusScope.of(context).unfocus();
    final provider = context.read<CgpaProvider>();
    final u = provider.selectedUniversity;

    final cgpaInput = double.tryParse(_cgpaController.text);
    if (cgpaInput == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid numeric CGPA')),
      );
      return;
    }

    final maxScale = u.id == 'mumbai_uni' ? 10.0 : u.gradingScale.toDouble();
    if (cgpaInput > maxScale || cgpaInput < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a CGPA between 0 and ${maxScale.toInt()}')),
      );
      return;
    }

    provider.calculateFromCgpa(cgpaInput);
    final percentage = provider.currentPercentage;
    final classification = u.getClassification(percentage);
    final letterGrade = u.getLetterGrade(cgpaInput, u.gradingScale);

    final historyEntry = {
      'type': 'Quick Convert',
      'university_name': u.shortName,
      'cgpa': cgpaInput.toStringAsFixed(2),
      'percentage': percentage.toStringAsFixed(2),
      'grade': letterGrade,
      'classification': classification,
      'date': DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
    };
    await provider.saveToHistory(historyEntry);

    if (!context.mounted) return;
    AdService().onCalculationDone(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          title: 'Quick Conversion Result',
          cgpa: cgpaInput,
          percentage: percentage,
          classification: classification,
          letterGrade: letterGrade,
          formulaUsed: u.formulaDescription,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CgpaProvider>();
    final u = provider.selectedUniversity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick CGPA → Percentage'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Using', style: GoogleFonts.inter(color: Theme.of(context).hintColor)),
                    const SizedBox(height: 4),
                    Text(
                      u.name,
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Change default university from Settings',
                      style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).hintColor),
                    ),
                  ],
                ),
              ),
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
                  autofocus: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    LengthLimitingTextInputFormatter(5),
                  ],
                  decoration: InputDecoration(
                    hintText: 'e.g. 8.5',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    suffixText: '/ ${u.id == 'mumbai_uni' ? 10 : u.gradingScale}',
                  ),
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.accentColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Convert Now',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
