import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../providers/cgpa_provider.dart';
import '../widgets/ad_banner_widget.dart';
import 'converter_screen.dart';
import 'semester_screen.dart';
import 'overall_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final history = context.watch<CgpaProvider>().calculationHistory;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GradeAstra',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.school, color: Color(0xFF1565C0)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black54),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, Student! 👋',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                'What do you want to calculate today?',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildFeatureGrid(context),
              const SizedBox(height: 32),
              Text(
                'Recent Calculations',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _buildRecentCalculations(history),
              const SizedBox(height: 24),
              const AdBannerWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      {
        'title': 'CGPA → %',
        'subtitle': 'Convert to percentage',
        'icon': Icons.calculate,
        'color': const Color(0xFFE3F2FD),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConverterScreen()))
      },
      {
        'title': 'Semester GPA',
        'subtitle': 'Calculate SGPA',
        'icon': Icons.table_chart,
        'color': const Color(0xFFFFF3E0),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SemesterScreen()))
      },
      {
        'title': 'Overall CGPA',
        'subtitle': 'Multi-semester',
        'icon': Icons.trending_up,
        'color': const Color(0xFFE8F5E9),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OverallScreen()))
      },
      {
        'title': 'History',
        'subtitle': 'Past calculations',
        'icon': Icons.history,
        'color': const Color(0xFFFCE4EC),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()))
      },
    ];

    return AnimationLimiter(
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
        children: List.generate(features.length, (index) {
          final item = features[index];
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: _buildFeatureCard(
                  title: item['title'] as String,
                  subtitle: item['subtitle'] as String,
                  icon: item['icon'] as IconData,
                  color: item['color'] as Color,
                  onTap: item['onTap'] as VoidCallback,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: Colors.black87),
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCalculations(List<Map<String, dynamic>> history) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Text(
              'No recent calculations',
              style: GoogleFonts.inter(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final recent = history.take(3).toList();
    return Column(
      children: recent.map((item) {
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF1565C0),
              child: Icon(Icons.calculate, color: Colors.white, size: 20),
            ),
            title: Text(item['university_name'] ?? 'Calculation', style: GoogleFonts.poppins(fontSize: 14)),
            subtitle: Text(item['date'] ?? '', style: GoogleFonts.inter(fontSize: 12)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item['cgpa']} CGPA',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF1565C0)),
                ),
                Text(
                  '${item['percentage']}%',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
