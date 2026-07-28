import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/cgpa_provider.dart';
import 'providers/theme_provider.dart';
import 'services/ad_service.dart';
import 'services/one_signal_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AdMob with error handling
  try {
    await MobileAds.instance.initialize();
    AdService().initialize();
  } catch (e) {
    // Ignore AdMob initialization errors in release builds.
  }

  // Initialize OneSignal for push notifications
  try {
    await OneSignalService().initialize();
    await Future.delayed(const Duration(seconds: 3));
    await OneSignalService().requestPermission();
  } catch (e) {
    // Ignore OneSignal initialization errors in release builds.
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CgpaProvider()),
      ],
      child: const CGPACalculatorApp(),
    ),
  );
}
