import 'package:google_mobile_ads/package_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AdService {
  static const String _calcCountKey = 'calculation_count';
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AppConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
          _interstitialAd?.dispose();
        },
      ),
    );
  }

  Future<void> showInterstitialIfReady() async {
    final prefs = await SharedPreferences.getInstance();
    int calcCount = (prefs.getInt(_calcCountKey) ?? 0) + 1;
    await prefs.setInt(_calcCountKey, calcCount);

    if (calcCount % 3 == 0) {
      if (_isInterstitialAdReady && _interstitialAd != null) {
        _interstitialAd?.show();
        _isInterstitialAdReady = false;
        _interstitialAd = null;
        loadInterstitialAd();
      }
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
