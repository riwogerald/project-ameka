import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';

class AdManager extends ChangeNotifier {
  static AdManager? _instance;
  static AdManager get instance => _instance ??= AdManager._();
  
  AdManager._();
  
  // Ad Unit IDs (Test IDs for development)
  static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  BannerAd? _bannerAd;
  
  bool _isInterstitialAdReady = false;
  bool _isRewardedAdReady = false;
  bool _isBannerAdReady = false;
  
  int _adsShownThisHour = 0;
  DateTime _lastAdResetTime = DateTime.now();
  
  // Getters
  bool get isInterstitialAdReady => _isInterstitialAdReady;
  bool get isRewardedAdReady => _isRewardedAdReady;
  bool get isBannerAdReady => _isBannerAdReady;
  BannerAd? get bannerAd => _bannerAd;
  
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadInterstitialAd();
    _loadRewardedAd();
    _loadBannerAd();
    
    debugPrint('AdManager initialized');
  }
  
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          notifyListeners();
          debugPrint('Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
          debugPrint('Interstitial ad failed to load: $error');
        },
      ),
    );
  }
  
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          notifyListeners();
          debugPrint('Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdReady = false;
          debugPrint('Rewarded ad failed to load: $error');
        },
      ),
    );
  }
  
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdReady = true;
          notifyListeners();
          debugPrint('Banner ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerAdReady = false;
          ad.dispose();
          debugPrint('Banner ad failed to load: $error');
        },
      ),
    );
    
    _bannerAd?.load();
  }
  
  Future<void> showInterstitialAd({VoidCallback? onComplete}) async {
    if (!_canShowAd()) {
      onComplete?.call();
      return;
    }
    
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isInterstitialAdReady = false;
          _adsShownThisHour++;
          _loadInterstitialAd(); // Load next ad
          onComplete?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isInterstitialAdReady = false;
          _loadInterstitialAd();
          onComplete?.call();
        },
      );
      
      await _interstitialAd!.show();
    } else {
      onComplete?.call();
    }
  }
  
  Future<void> showRewardedAd({
    required VoidCallback onRewarded,
    VoidCallback? onFailed,
  }) async {
    if (_isRewardedAdReady && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isRewardedAdReady = false;
          _loadRewardedAd(); // Load next ad
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isRewardedAdReady = false;
          _loadRewardedAd();
          onFailed?.call();
        },
      );
      
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onRewarded();
        },
      );
    } else {
      onFailed?.call();
    }
  }
  
  bool _canShowAd() {
    // Reset counter every hour
    if (DateTime.now().difference(_lastAdResetTime).inHours >= 1) {
      _adsShownThisHour = 0;
      _lastAdResetTime = DateTime.now();
    }
    
    return _adsShownThisHour < 5; // Limit to 5 ads per hour
  }
  
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }
}