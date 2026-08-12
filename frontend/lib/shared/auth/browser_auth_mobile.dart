import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import 'browser_auth.dart';

BrowserAuth getBrowserAuth() => BrowserAuthMobile();

class BrowserAuthMobile implements BrowserAuth {
  static const _callbackScheme = 'net.croudebush.sprout';

  @override
  String get callbackUrl => '$_callbackScheme://callback';

  @override
  String get currentWebUrl => throw UnsupportedError('Not available on mobile');

  @override
  Future<String> openPopup(String url, {String? webSuccessMessage}) async {
    return await FlutterWebAuth2.authenticate(
      url: url,
      callbackUrlScheme: _callbackScheme,
      options: const FlutterWebAuth2Options(
        customTabsPackageOrder: [
          'com.android.chrome',
          'com.chrome.beta',
          'com.sec.android.app.sbrowser',
          'com.brave.browser',
        ],
      ),
    );
  }

  @override
  Future<void> redirectTab(String url) async {
    // Mobile doesn't redirect tabs, it just opens the custom tab view
    await openPopup(url);
  }
}
