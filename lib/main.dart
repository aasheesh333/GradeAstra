import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/cgpa_provider.dart';
import 'providers/theme_provider.dart';
import 'services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AdMob
  final AdService adService = AdService();
  await adService.initialize();

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
