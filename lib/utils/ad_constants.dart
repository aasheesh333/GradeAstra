class AdConstants {
  static const bool kIsProductionAds = true; // Use dart environment variables

  static String get bannerAdUnitId {
    const String envId = String.fromEnvironment('ADMOB_BANNER_ID', defaultValue: '');
    if (kIsProductionAds && envId.isNotEmpty) {
      return envId;
    } else {
      return 'ca-app-pub-3940256099942544/6300978111';
    }
  }

  static String get interstitialAdUnitId {
    const String envId = String.fromEnvironment('ADMOB_INTERSTITIAL_ID', defaultValue: '');
    if (kIsProductionAds && envId.isNotEmpty) {
      return envId;
    } else {
      return 'ca-app-pub-3940256099942544/1033173712';
    }
  }
}
