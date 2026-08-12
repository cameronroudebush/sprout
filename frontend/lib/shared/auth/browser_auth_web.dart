import 'dart:async';
import 'dart:html' as html;

import 'browser_auth.dart';

BrowserAuth getBrowserAuth() => BrowserAuthWeb();

class BrowserAuthWeb implements BrowserAuth {
  @override
  String get callbackUrl => '${html.window.location.origin}/provider-callback.html';

  @override
  String get currentWebUrl => html.window.location.href.split('#').first;

  @override
  Future<void> redirectTab(String url) async {
    html.window.location.assign(url);
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<String> openPopup(String url, {String? webSuccessMessage}) async {
    final completer = Completer<String>();

    const width = 500;
    const height = 700;
    final windowLeft = html.window.screenX ?? 0;
    final windowTop = html.window.screenY ?? 0;
    final windowWidth = html.window.outerWidth;
    final windowHeight = html.window.outerHeight;
    final left = windowLeft + ((windowWidth - width) ~/ 2);
    final top = windowTop + ((windowHeight - height) ~/ 2);
    final windowFeatures = 'width=$width,height=$height,top=$top,left=$left,status=no,resizable=yes,scrollbars=yes';

    final popupWindow = html.window.open(url, 'AuthWindow', windowFeatures);

    StreamSubscription<html.MessageEvent>? messageSub;
    Timer? pollTimer;

    void cleanup() {
      messageSub?.cancel();
      pollTimer?.cancel();
    }

    messageSub = html.window.onMessage.listen((event) {
      if (webSuccessMessage != null && event.data == webSuccessMessage) {
        cleanup();
        completer.complete(event.data.toString());
      }
    });

    pollTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (popupWindow.closed ?? true) {
        cleanup();
        if (!completer.isCompleted) {
          completer.completeError("Auth connection closed.");
        }
      }
    });

    return completer.future;
  }
}
