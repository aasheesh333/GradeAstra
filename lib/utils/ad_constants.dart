class AdConstants {
  static const bool kIsProductionAds = false;

  static String get bannerAdUnitId {
    if (kIsProductionAds) {
      return 'YOUR_REAL_BANNER_ID';
    } else {
      return 'ca-app-pub-3940256099942544/6300978111';
    }
  }

  static String get interstitialAdUnitId {
    if (kIsProductionAds) {
      return 'YOUR_REAL_INTERSTITIAL_ID';
    } else {
      return 'ca-app-pub-3940256099942544/1033173712';
    }
  }
}
