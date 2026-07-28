import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/theme_provider.dart';
import 'utils/constants.dart';
import 'screens/splash_screen.dart';
import 'widgets/persistent_banner_ad.dart';

class CGPACalculatorApp extends StatelessWidget {
  const CGPACalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'CGPA Calculator',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppConstants.primaryColor,
        colorScheme: ColorScheme.fromSeed(seedColor: AppConstants.primaryColor),
        fontFamily: GoogleFonts.poppins().fontFamily,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        primaryColor: AppConstants.primaryColor,
        colorScheme: ColorScheme.fromSeed(seedColor: AppConstants.primaryColor, brightness: Brightness.dark),
        fontFamily: GoogleFonts.poppins().fontFamily,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: const CardTheme(color: Color(0xFF1E1E2E)),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      builder: (context, child) {
        return Scaffold(
          body: child ?? const SizedBox.shrink(),
          bottomNavigationBar: const PersistentBannerAd(),
        );
      },
      home: const SplashScreen(),
    );
  }
}
