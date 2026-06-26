import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsManager {
  AdsManager._();

  static final AdsManager instance = AdsManager._();

  static const String _androidInterstitialTestId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _iosInterstitialTestId =
      'ca-app-pub-3940256099942544/4411468910';
  static const String _androidRewardedTestId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _iosRewardedTestId =
      'ca-app-pub-3940256099942544/1712485313';

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _interstitialReady = false;
  bool _rewardedReady = false;

  bool get _isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  String? get _interstitialAdUnitId {
    if (!_isSupportedPlatform) {
      return null;
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => _iosInterstitialTestId,
      _ => _androidInterstitialTestId,
    };
  }

  String? get _rewardedAdUnitId {
    if (!_isSupportedPlatform) {
      return null;
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => _iosRewardedTestId,
      _ => _androidRewardedTestId,
    };
  }

  Future<void> initialize() async {
    if (!_isSupportedPlatform) {
      debugPrint('Ads skipped on unsupported platform.');
      return;
    }

    try {
      await MobileAds.instance.initialize();
      await Future.wait<void>(<Future<void>>[
        _loadInterstitial(),
        _loadRewarded(),
      ]);
    } catch (error, stackTrace) {
      debugPrint('Ads initialization error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  bool get isInterstitialReady => _interstitialReady && _interstitialAd != null;
  bool get isRewardedReady => _rewardedReady && _rewardedAd != null;

  Future<void> _loadInterstitial() async {
    final adUnitId = _interstitialAdUnitId;
    if (adUnitId == null) {
      return;
    }

    _interstitialReady = false;
    try {
      await InterstitialAd.load(
        adUnitId: kDebugMode ? adUnitId : adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd?.dispose();
            _interstitialAd = ad;
            _interstitialReady = true;
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _interstitialAd = null;
                _interstitialReady = false;
                unawaited(_loadInterstitial());
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint('Interstitial failed to show: $error');
                ad.dispose();
                _interstitialAd = null;
                _interstitialReady = false;
                unawaited(_loadInterstitial());
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint('Interstitial failed to load: $error');
            _interstitialAd = null;
            _interstitialReady = false;
          },
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Interstitial load error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _loadRewarded() async {
    final adUnitId = _rewardedAdUnitId;
    if (adUnitId == null) {
      return;
    }

    _rewardedReady = false;
    try {
      await RewardedAd.load(
        adUnitId: kDebugMode ? adUnitId : adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd?.dispose();
            _rewardedAd = ad;
            _rewardedReady = true;
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _rewardedAd = null;
                _rewardedReady = false;
                unawaited(_loadRewarded());
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint('Rewarded failed to show: $error');
                ad.dispose();
                _rewardedAd = null;
                _rewardedReady = false;
                unawaited(_loadRewarded());
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint('Rewarded failed to load: $error');
            _rewardedAd = null;
            _rewardedReady = false;
          },
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Rewarded load error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> showInterstitial() async {
    if (!isInterstitialReady) {
      return;
    }

    try {
      await _interstitialAd?.show();
    } catch (error, stackTrace) {
      debugPrint('Show interstitial error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> showRewarded({
    required void Function(RewardItem reward) onEarned,
  }) async {
    if (!isRewardedReady) {
      return;
    }

    try {
      await _rewardedAd?.show(
        onUserEarnedReward: (_, reward) => onEarned(reward),
      );
    } catch (error, stackTrace) {
      debugPrint('Show rewarded error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd = null;
    _rewardedAd = null;
    _interstitialReady = false;
    _rewardedReady = false;
  }
}
