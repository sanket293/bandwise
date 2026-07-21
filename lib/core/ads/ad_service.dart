import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';

/// Owns SDK init, the app-open ad (cold launch), and the once-per-day rewarded
/// ad. Banners are created per-widget by [AdaptiveBanner].
///
/// Design rule from the brief: NO interstitials, and ads must never interrupt an
/// in-progress scoring interaction. The app-open ad shows only on cold launch;
/// the rewarded ad is user-initiated. There is no code path that shows a
/// full-screen ad during simulator use.
class AdService {
  AdService();

  bool _initialized = false;
  AppOpenAd? _appOpenAd;
  RewardedAd? _rewardedAd;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await MobileAds.instance.initialize();
      _loadAppOpenAd();
      _loadRewardedAd();
    } catch (e) {
      debugPrint('AdService init failed (ads disabled this session): $e');
    }
  }

  // --- App open (cold launch only) ---

  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: AdConfig.appOpenUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) => _appOpenAd = ad,
        onAdFailedToLoad: (err) => debugPrint('AppOpenAd failed: $err'),
      ),
    );
  }

  /// Shows the app-open ad once if it is ready. Safe to call on cold start.
  void showAppOpenIfAvailable() {
    final ad = _appOpenAd;
    if (ad == null) return;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpenAd = null;
        _loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _appOpenAd = null;
        _loadAppOpenAd();
      },
    );
    ad.show();
    _appOpenAd = null;
  }

  // --- Rewarded (once per day, user-initiated) ---

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdConfig.rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (err) => debugPrint('RewardedAd failed: $err'),
      ),
    );
  }

  bool get isRewardedReady => _rewardedAd != null;

  /// Shows the rewarded ad; invokes [onReward] if the user earns it.
  /// Returns false if no ad was ready.
  bool showRewarded({required VoidCallback onReward}) {
    final ad = _rewardedAd;
    if (ad == null) {
      _loadRewardedAd();
      return false;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
      },
    );
    ad.show(onUserEarnedReward: (_, __) => onReward());
    _rewardedAd = null;
    return true;
  }

  void dispose() {
    _appOpenAd?.dispose();
    _rewardedAd?.dispose();
  }
}

final adServiceProvider = Provider<AdService>((ref) {
  final service = AdService();
  ref.onDispose(service.dispose);
  return service;
});
