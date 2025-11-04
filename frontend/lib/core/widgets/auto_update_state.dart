import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/provider/sse.dart';

///
/// This widget provides default functionality that allows us to automatically populate
///   necessary data for our current display. We do this by having the developer implement
///   a [loadData] function that is then used to initialize data after the first frame is
///   loaded. Then we also subscribe to SSE events and when forced data is requested, this
///   callback is re-used.
abstract class AutoUpdateState<T extends StatefulWidget, Z extends BaseProvider> extends State<T>
    with WidgetsBindingObserver {
  final _sseProvider = ServiceLocator.get<SSEProvider>();
  StreamSubscription<SSEData>? _sseSubscription;

  /// If this state is loading data
  bool _isLoading = false;

  /// This function is what will be called to load data for display on this widget.
  abstract Future<dynamic> Function(bool showLoaders) loadData;

  /// The provider that is in use for this state updating
  abstract Z provider;

  /// Returns if any element that contains this elements data is loading
  bool get isLoading => provider.isLoading || _isLoading;

  /// Wraps the load data call from the implementor with state setting for loading status
  Future<void> _loadDataWrapper(bool showProviderLoaders) async {
    setState(() {
      _isLoading = true;
    });
    await loadData(showProviderLoaders);
    setState(() {
      _isLoading = false;
    });
  }

  /// Set's up when we should call data loading capabilities
  void _setupData() {
    // After the first frame is rendered, load our initial data set
    //  We don't require that the spinners are shown here because the data should still be doing it's first load
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDataWrapper(false));
    // Listen to the SSE events to track when data needs to be reloaded
    _sseSubscription?.cancel(); // Cancel any previous subscription
    _sseSubscription = _sseProvider.onSSEEvent.listen((data) async {
      // If this is a force update, load new data and show spinners
      if (data.event == SSEDataEventEnum.forceUpdate) {
        onForceSync();
        await _loadDataWrapper(true);
      }
    });
  }

  /// When force sync is called via the SSE provider, this method will be called before the load data in-case you have any special handling
  void onForceSync() {}

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
