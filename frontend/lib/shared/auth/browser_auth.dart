import 'browser_auth_stub.dart'
    if (dart.library.html) 'browser_auth_web.dart'
    if (dart.library.io) 'browser_auth_mobile.dart';

/// A universal interface for handling platform-specific browser authentication
abstract class BrowserAuth {
  factory BrowserAuth() => getBrowserAuth();

  /// The standard redirect URI used to route back to Sprout
  String get callbackUrl;

  /// The current URL of the application (Web only). Throws on mobile.
  String get currentWebUrl;

  /// Opens an auth window. 
  /// - Mobile: Opens a Custom Tab and waits for the callback scheme. Returns the final redirect URL.
  /// - Web: Opens a centered popup and polls. If [webSuccessMessage] is provided, it waits for a postMessage matching it. Returns the message.
  Future<String> openPopup(String url, {String? webSuccessMessage});

  /// Redirects the current tab to a new URL (Web only). 
  Future<void> redirectTab(String url);
}