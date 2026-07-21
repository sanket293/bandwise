import 'dart:io' show Platform;

/// Central ad-unit configuration.
///
/// These are Google's OFFICIAL TEST ad unit IDs — safe to ship in development,
/// they never generate revenue and never risk an AdMob policy strike. Replace
/// each value with your real unit ID (and set [useTestIds] = false) before
/// release. The app IDs also need to go in AndroidManifest.xml / Info.plist.
class AdConfig {
  AdConfig._();

  /// Flip to false and fill in the real IDs below for a production build.
  static const bool useTestIds = true;

  // --- Test unit IDs (from https://developers.google.com/admob) ---
  static const _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const _testAppOpenAndroid = 'ca-app-pub-3940256099942544/9257395921';
  static const _testAppOpenIos = 'ca-app-pub-3940256099942544/5575463023';
  static const _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const _testRewardedIos = 'ca-app-pub-3940256099942544/1712485313';

  // --- TODO: real unit IDs for production ---
  static const _prodBannerAndroid = 'YOUR_ANDROID_BANNER_ID';
  static const _prodBannerIos = 'YOUR_IOS_BANNER_ID';
  static const _prodAppOpenAndroid = 'YOUR_ANDROID_APP_OPEN_ID';
  static const _prodAppOpenIos = 'YOUR_IOS_APP_OPEN_ID';
  static const _prodRewardedAndroid = 'YOUR_ANDROID_REWARDED_ID';
  static const _prodRewardedIos = 'YOUR_IOS_REWARDED_ID';

  static String get bannerUnitId => _pick(
        testAndroid: _testBannerAndroid,
        testIos: _testBannerIos,
        prodAndroid: _prodBannerAndroid,
        prodIos: _prodBannerIos,
      );

  static String get appOpenUnitId => _pick(
        testAndroid: _testAppOpenAndroid,
        testIos: _testAppOpenIos,
        prodAndroid: _prodAppOpenAndroid,
        prodIos: _prodAppOpenIos,
      );

  static String get rewardedUnitId => _pick(
        testAndroid: _testRewardedAndroid,
        testIos: _testRewardedIos,
        prodAndroid: _prodRewardedAndroid,
        prodIos: _prodRewardedIos,
      );

  static String _pick({
    required String testAndroid,
    required String testIos,
    required String prodAndroid,
    required String prodIos,
  }) {
    final isAndroid = Platform.isAndroid;
    if (useTestIds) return isAndroid ? testAndroid : testIos;
    return isAndroid ? prodAndroid : prodIos;
  }
}
