import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/cgpa_provider.dart';
import '../providers/theme_provider.dart';
import '../data/universities.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _appVersion = info.version;
        _buildNumber = info.buildNumber;
      });
    } catch (_) {}
  }

  void _showDefaultUniversityDialog(BuildContext context) {
    final provider = context.read<CgpaProvider>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Default University'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: universitiesData.length,
              itemBuilder: (context, index) {
                final u = universitiesData[index];
                return ListTile(
                  title: Text(u.name),
                  subtitle: Text(u.shortName),
                  trailing: provider.selectedUniversity.id == u.id ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    provider.selectUniversity(u);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final cgpaProvider = context.watch<CgpaProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Default University'),
            subtitle: Text(cgpaProvider.selectedUniversity.name),
            onTap: () => _showDefaultUniversityDialog(context),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(value),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Clear History', style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear History'),
                  content: const Text('Are you sure you want to clear all your calculation history?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        cgpaProvider.clearHistory();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('History cleared')));
                      },
                      child: const Text('Clear', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About CGPA Calculator'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: [
                      const Icon(Icons.school, color: AppConstants.primaryColor),
                      const SizedBox(width: 8),
                      Text(AppConstants.appName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _appVersion.isEmpty
                            ? 'Version 1.0.0'
                            : 'Version $_appVersion ($_buildNumber)',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text('Smart CGPA Calculator for Indian University Students.', style: GoogleFonts.inter()),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () async {
              final Uri url = Uri.parse(AppConstants.privacyPolicyUrl);
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open Privacy Policy')));
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Use'),
            onTap: () async {
              final Uri url = Uri.parse(AppConstants.termsOfUseUrl);
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open Terms of Use')));
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail),
            title: const Text('Contact us'),
            onTap: () async {
              final Uri url = Uri.parse(AppConstants.contactUsUrl);
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open Contact us')));
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Rate App'),
            onTap: () async {
              final Uri url = Uri.parse(AppConstants.playStoreUrl);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open Play Store')));
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
