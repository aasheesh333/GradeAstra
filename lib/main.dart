import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/cgpa_provider.dart';
import 'providers/theme_provider.dart';
import 'services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AdMob with error handling
  try {
    await MobileAds.instance.initialize();
    AdService().initialize();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('AdMob initialization failed: $e');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CgpaProvider()),
      ],
      child: const GradeAstraApp(),
    ),
  );
}
