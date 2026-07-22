import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  static const String _appId = String.fromEnvironment('ONESIGNAL_APP_ID');

  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized || _appId.isEmpty) return;

    try {
      if (kDebugMode) {
        OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      }

      OneSignal.initialize(_appId);
      _initialized = true;
    } catch (e) {
      // Silently ignore initialization failures in release builds.
    }
  }

  Future<bool> requestPermission() async {
    if (!_initialized || _appId.isEmpty) return false;
    try {
      return await OneSignal.Notifications.requestPermission(true);
    } catch (e) {
      return false;
    }
  }
}
