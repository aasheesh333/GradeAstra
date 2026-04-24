import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/cgpa_provider.dart';
import '../widgets/ad_banner_widget.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  Future<void> _exportPdf(BuildContext context, List<Map<String, dynamic>> history) async {
    if (history.isEmpty) return;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('GradeAstra', style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Calculation History', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 24),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Date', 'Type', 'University', 'CGPA', 'Percentage', 'Grade'],
                  ...history.map((item) => [
                        item['date'] ?? '',
                        item['type'] ?? '',
                        item['university_name'] ?? '',
                        item['cgpa']?.toString() ?? '',
                        '${item['percentage']}%',
                        item['grade'] ?? '',
                      ]),
                ],
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/GradeAstra_History.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'My GradeAstra Calculation History');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CgpaProvider>();
    final history = provider.calculationHistory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculation History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _exportPdf(context, history),
            tooltip: 'Export as PDF',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              if (history.isEmpty) return;
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear History'),
                  content: const Text('Are you sure you want to delete all history?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        provider.clearHistory();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_toggle_off, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No calculations yet', style: GoogleFonts.inter(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return Dismissible(
                        key: Key(item['date'] + index.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          provider.removeHistoryEntry(index);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text('${item['type']} - ${item['university_name']}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text(item['date'], style: GoogleFonts.inter(fontSize: 12)),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${item['cgpa']} CGPA', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF1565C0))),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                  child: Text('${item['percentage']}%', style: GoogleFonts.inter(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const AdBannerWidget(),
        ],
      ),
    );
  }
}
