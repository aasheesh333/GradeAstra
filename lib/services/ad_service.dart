import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/ad_constants.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _interstitialLoading = false;
  bool _rewardedLoading = false;
  int _sessionCalculationCount = 0;
  DateTime? _lastInterstitialShown;
  static const int _interstitialCooldownSecs = 90;

  Future<void> initialize() async {
    loadInterstitialAd();
    loadRewardedAd();
  }

  void loadInterstitialAd() {
    if (_interstitialLoading || _interstitialAd != null) return;
    _interstitialLoading = true;

    InterstitialAd.load(
      adUnitId: AdConstants.kInterstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoading = false;
        },
        onAdFailedToLoad: (error) {
          _interstitialLoading = false;
          Future.delayed(const Duration(minutes: 2), () {
            loadInterstitialAd();
          });
        },
      ),
    );
  }

  void loadRewardedAd() {
    if (_rewardedLoading || _rewardedAd != null) return;
    _rewardedLoading = false;

    RewardedAd.load(
      adUnitId: AdConstants.kRewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          _rewardedLoading = false;
          Future.delayed(const Duration(minutes: 2), () {
            loadRewardedAd();
          });
        },
      ),
    );
  }

  void onCalculationDone(BuildContext context) {
    _sessionCalculationCount++;

    if (_sessionCalculationCount % 4 == 0) {
      _showRewardedAd(context);
      return;
    }

    if (_sessionCalculationCount % 2 == 0) {
      DateTime now = DateTime.now();
      if (_lastInterstitialShown == null || now.difference(_lastInterstitialShown!).inSeconds >= _interstitialCooldownSecs) {
        _showInterstitialAd(context);
        return;
      }
    }
  }

  void _showInterstitialAd(BuildContext context) {
    if (_interstitialAd == null) {
      loadInterstitialAd();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
      },
    );

    _interstitialAd!.show();
    _lastInterstitialShown = DateTime.now();
    _interstitialAd = null;
  }

  void _showRewardedAd(BuildContext context) {
    if (_rewardedAd == null) {
      loadRewardedAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (ad, reward) {});
    _rewardedAd = null;
  }

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
