import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/constants.dart';



class ResultScreen extends StatefulWidget {
  final String title;
  final double cgpa;
  final double percentage;
  final String classification;
  final String letterGrade;
  final String formulaUsed;

  const ResultScreen({
    super.key,
    required this.title,
    required this.cgpa,
    required this.percentage,
    required this.classification,
    required this.letterGrade,
    required this.formulaUsed,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  bool _isSharing = false;

  Future<void> _shareResult() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      final image = await _screenshotController.capture();
      if (image == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = await File('${directory.path}/result.png').create();
      await imagePath.writeAsBytes(image);

      await Share.shareXFiles([XFile(imagePath.path)], text: 'Check out my ${widget.title} from GradeAstra!');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to share result. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color classificationColor = Colors.green;
    if (widget.classification == 'Fail') classificationColor = Colors.red;
    else if (widget.classification == 'Second Class' || widget.classification == 'Pass Class') classificationColor = Colors.orange;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(icon: const Icon(Icons.share), tooltip: 'Share Result', onPressed: _isSharing ? null : _shareResult)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Screenshot(
              controller: _screenshotController,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    Text('CGPA', style: GoogleFonts.inter(fontSize: 16, color: Colors.grey)),
                    Text(widget.cgpa.toStringAsFixed(2), style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.bold, color: AppConstants.primaryColor)),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text('Equivalent Percentage', style: GoogleFonts.inter(fontSize: 16, color: Colors.grey)),
                    Text('${widget.percentage.toStringAsFixed(2)}%', style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: AppConstants.accentColor)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Chip(
                          label: Text(widget.classification, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                          backgroundColor: classificationColor,
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text('Grade: ${widget.letterGrade}', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                          backgroundColor: AppConstants.primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Formula Used:', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                    Text(widget.formulaUsed, style: GoogleFonts.inter(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey[700]), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    Text('Calculated via GradeAstra', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
