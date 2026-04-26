import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/constants.dart';
import '../utils/ad_constants.dart';

class AdService {
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdConstants.interstitialAdUnitId,
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
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd?.show();
      _isInterstitialAdReady = false;
      _interstitialAd = null;
      loadInterstitialAd();
    } else {
      loadInterstitialAd();
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
