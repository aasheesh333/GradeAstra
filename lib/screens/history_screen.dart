import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/cgpa_provider.dart';


class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<void> _exportPdf(BuildContext context, List<Map<String, dynamic>> history) async {
    if (history.isEmpty) return;

    try {
      final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('CGPA Calculator', style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Calculation History', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 24),
              pw.TableHelper.fromTextArray(
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
    final file = File('${output.path}/CGPACalculator_History.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'My CGPA Calculator Calculation History');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export PDF. Please try again.')),
        );
      }
    }
  }

  Future<void> _exportCsv(BuildContext context, List<Map<String, dynamic>> history) async {
    if (history.isEmpty) return;

    try {
      final rows = [
        ['Date', 'Type', 'University', 'CGPA', 'Percentage', 'Grade', 'Classification'],
        ...history.map((item) => [
              item['date']?.toString() ?? '',
              item['type']?.toString() ?? '',
              item['university_name']?.toString() ?? '',
              item['cgpa']?.toString() ?? '',
              item['percentage']?.toString() ?? '',
              item['grade']?.toString() ?? '',
              item['classification']?.toString() ?? '',
            ]),
      ];

      String _escapeCsvField(String field) {
        final needsQuotes = field.contains(',') || field.contains('"') || field.contains('\n') || field.contains('\r');
        if (!needsQuotes) return field;
        final escaped = field.replaceAll('"', '""');
        return '"$escaped"';
      }

      final csvContent = rows.map((row) => row.map(_escapeCsvField).join(',')).join('\n');

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/CGPACalculator_History.csv');
      await file.writeAsString(csvContent);

      await Share.shareXFiles([XFile(file.path)], text: 'My CGPA Calculator History (CSV)');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export CSV. Please try again.')),
        );
      }
    }
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
            icon: const Icon(Icons.download),
            onPressed: () => _exportCsv(context, history),
            tooltip: 'Export as CSV',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear All History',
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
                        key: Key('${item['date'] ?? ''}$index'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Entry'),
                              content: const Text('Remove this calculation from history?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          ) ?? false;
                        },
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
        ],
      ),
    );
  }
}
