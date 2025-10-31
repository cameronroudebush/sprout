import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/provider/sse.dart';

///
/// This widget provides default functionality that allows us to automatically populate
///   necessary data for our current display. We do this by having the developer implement
///   a [loadData] function that is then used to initialize data after the first frame is
///   loaded. Then we also subscribe to SSE events and when forced data is requested, this
///   callback is re-used.
abstract class AutoUpdateState<T extends StatefulWidget> extends State<T> with WidgetsBindingObserver {
  final _sseProvider = ServiceLocator.get<SSEProvider>();
  StreamSubscription<SSEData>? _sseSubscription;

  /// This function is what will be called to load data for display on this widget.
  abstract Future<dynamic> Function(bool showLoaders) loadData;

  /// Set's up when we should call data loading capabilities
  void _setupData() {
    // After the first frame is rendered, load our initial data set
    //  We don't require that the spinners are shown here because the data should still be doing it's first load
    WidgetsBinding.instance.addPostFrameCallback((_) => loadData(false));
    // Listen to the SSE events to track when data needs to be reloaded
    _sseSubscription?.cancel(); // Cancel any previous subscription
    _sseSubscription = _sseProvider.onSSEEvent.listen((data) {
      // If this is a force update, load new data and show spinners
      if (data.event == SSEDataEventEnum.forceUpdate) loadData(true);
    });
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) WidgetsBinding.instance.addObserver(this);
    _setupData();
  }

  @override
  void dispose() {
    _sseSubscription?.cancel();
    if (!kIsWeb) WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // We use this function to determine when the mobile app has resumed it's state. This
    //  allows us to re-request data for any component using the auto state updater.
    if (state == AppLifecycleState.resumed) {
      // This means the app has resumed after being woken up from the background. So refresh our data.
      loadData(true);
    }
  }
}
