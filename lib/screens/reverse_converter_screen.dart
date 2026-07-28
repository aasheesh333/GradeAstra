import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/cgpa_provider.dart';
import '../data/universities.dart';
import '../models/university_model.dart';
import '../widgets/university_selector.dart';
import '../utils/constants.dart';
import '../services/ad_service.dart';
import 'result_screen.dart';

class ReverseConverterScreen extends StatefulWidget {
  const ReverseConverterScreen({super.key});

  @override
  State<ReverseConverterScreen> createState() => _ReverseConverterScreenState();
}

class _ReverseConverterScreenState extends State<ReverseConverterScreen> {
  final TextEditingController _percentageController = TextEditingController();

  @override
  void dispose() {
    _percentageController.dispose();
    super.dispose();
  }

  void _calculate() async {
    FocusScope.of(context).unfocus();
    final provider = context.read<CgpaProvider>();
    final u = provider.selectedUniversity;

    if (!u.supportsReverseConversion) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected university does not support reverse conversion yet')),
      );
      return;
    }

    final percentageInput = double.tryParse(_percentageController.text);
    if (percentageInput == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid percentage')),
      );
      return;
    }

    if (percentageInput < 0 || percentageInput > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a percentage between 0 and 100')),
      );
      return;
    }

    final cgpa = u.calculateCgpaFromPercentage(percentageInput);
    final letterGrade = u.getLetterGrade(cgpa, u.gradingScale);
    final classification = u.getClassification(percentageInput);

    final historyEntry = {
      'type': 'Reverse Converter',
      'university_name': u.shortName,
      'cgpa': cgpa.toStringAsFixed(2),
      'percentage': percentageInput.toStringAsFixed(2),
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
          title: 'Reverse Conversion Result',
          cgpa: cgpa,
          percentage: percentageInput,
          classification: classification,
          letterGrade: letterGrade,
          formulaUsed: 'Reverse of: ${u.formulaDescription}',
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
        title: const Text('Percentage to CGPA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Formula Info',
            onPressed: () => _showFormulaInfo(context, u),
          ),
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
              universities: universitiesData.where((u) => u.supportsReverseConversion).toList(),
              selectedUniversity: u.supportsReverseConversion ? u : universitiesData.firstWhere((u) => u.supportsReverseConversion),
              onChanged: (u) => provider.selectUniversity(u),
            ),
            const SizedBox(height: 24),
            Text('Enter your Percentage', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _percentageController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: InputDecoration(
                    hintText: 'e.g. 85.5',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    suffixText: '%',
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
                'Calculate CGPA',
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
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
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
