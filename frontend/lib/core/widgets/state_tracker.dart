import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/provider/sse.dart';

// Assuming you access the global observer here, or inject it via ServiceLocator
// import 'main.dart' show routeObserver;

class DataRequest<P extends BaseProvider, T> {
  final P provider;
  final Future<T?> Function(P provider, bool forceUpdate) onLoad;
  final T? Function(P provider)? getFromProvider;
  final bool isRequired;
  T? value;

  DataRequest({required this.provider, required this.onLoad, this.getFromProvider, this.isRequired = true});
}

abstract class StateTracker<T extends StatefulWidget> extends State<T> with WidgetsBindingObserver, RouteAware {
  final _sseProvider = ServiceLocator.get<SSEProvider>();
  final RouteObserver<ModalRoute> _routeObserver = ServiceLocator.routeObserver;

  StreamSubscription<SSEData>? _sseSubscription;

  /// The last time we preformed an update request per component name. Used to debounce how often we request data.
  ///   We use a static map so we can reference each widget across contexts.
  static Map<String, DateTime> lastUpdateTimes = <String, DateTime>{};

  /// Internal loading state
  bool _isLoading = false;

  // Flag to track if we missed an update while in background
  bool _markedForUpdate = false;

  Map<dynamic, DataRequest> get requests;

  /// Returns true if the component is currently fetching any data.
  bool get isLoading => _isLoading;

  /// Returns true only if ALL [DataRequest]s marked as [isRequired]
  /// have non-null [value]s.
  bool get hasValidData {
    return requests.values.where((req) => req.isRequired).every((req) => req.value != null);
  }

  /// Returns a name for the current widget
  get widgetName {
    return "$runtimeType";
  }

  /// Sets the current loading status and triggers a rebuild
  void setLoadingStatus(bool status) {
    if (mounted && _isLoading != status) {
      setState(() {
        _isLoading = status;
      });
    }
  }

  /// Iterates through all registered [requests], executes their onLoad functions,
  /// and updates their local values.
  /// [showLoaders] If we should show the loaders when required that we are loading data
  /// [forceUpdate] If we should trigger a force update to our requests to tell them to grab new data even if we already have data for them
  /// [checkLastUpdateTime] If we should check the last time we requested data to determine if we should grab new data. Enabled by default.
  Future<void> loadData({bool forceUpdate = false, bool showLoaders = true, bool checkLastUpdateTime = true}) async {
    if (requests.isEmpty) return;
    DateTime? lastUpdateTime = lastUpdateTimes[widgetName];

    // If the last update time is < the last force update, require new data to load
    final lastForceEvent = _sseProvider.lastEvents[SSEDataEventEnum.forceUpdate]?.timestamp;
    if (lastUpdateTime != null &&
        lastForceEvent != null &&
        lastUpdateTime.millisecondsSinceEpoch < lastForceEvent.millisecondsSinceEpoch) {
      lastUpdateTime = null;
      forceUpdate = true;
    }

    // If we haven't waited long enough since the last update, or we don't care about the last update time, ignore this request
    if (lastUpdateTime != null && checkLastUpdateTime) {
      final timeDiffMil = DateTime.now().millisecondsSinceEpoch - lastUpdateTime.millisecondsSinceEpoch;
      // If we have less than a 20 minute difference, ignore the fetch request
      if (timeDiffMil < (20 * 60000)) return;
    }

    // Identify which requests actually need fetching
    List<MapEntry<dynamic, DataRequest>> needsFetching = [];

    for (var entry in requests.entries) {
      final req = entry.value;

      // Try to get cached data first
      final cachedData = (req as dynamic).getFromProvider?.call(req.provider);
      bool isCacheEmpty =
          cachedData == null || (cachedData is List && cachedData.isEmpty) || (cachedData is num && cachedData == 0);

      if (!forceUpdate && !isCacheEmpty) {
        // Data exists and we aren't forced to update: Use cached, skip load.
        req.value = cachedData;
      } else {
        // Data is missing OR we are forced to update: Mark for fetch.
        needsFetching.add(entry);
      }
    }

    // If nothing needs fetching, just update UI with cached values and exit
    if (needsFetching.isEmpty) {
      if (mounted) setState(() {});
      return;
    }

    // Only show loader if we have actual work to do
    if (mounted && showLoaders) {
      setLoadingStatus(true);
    }

    try {
      // Run onLoad ONLY for the requests that need it
      lastUpdateTimes[widgetName] = DateTime.now();
      final futures = needsFetching.map((entry) async {
        final request = entry.value;
        try {
          final result = await (request as dynamic).onLoad(request.provider, forceUpdate);
          request.value = result;
        } catch (e) {
          debugPrint("Error loading data for key ${entry.key}: $e");
          request.value = null;
        }
      });

      await Future.wait(futures);
    } finally {
      if (mounted) {
        setLoadingStatus(false);
      }
    }
  }

  /// Sets up when we should call data loading capabilities
  void _setupData() {
    // After the first frame is rendered, load our initial data set
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Check if providers are initialized if necessary, or just load
      await loadData();
    });

    // Listen to the SSE events to track when data needs to be reloaded
    _sseSubscription?.cancel();
    _sseSubscription = _sseProvider.onSSEEvent.listen((data) async {
      // If this is a force update, load new data and show spinners
      if (data.event == SSEDataEventEnum.forceUpdate) {
        final isVisible = ModalRoute.of(context)?.isCurrent ?? false;

        if (isVisible) {
          await loadData(forceUpdate: true, checkLastUpdateTime: false);
          onForceSync();
        } else {
          // If hidden, mark dirty but DO NOT load
          _markedForUpdate = true;
        }
      }
    });
  }

  /// When force sync is called via the SSE provider, this method will be called
  /// before the load data in-case you have any special handling
  void onForceSync() {}

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) WidgetsBinding.instance.addObserver(this);
    _setupData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      _routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    _sseSubscription?.cancel();
    if (!kIsWeb) WidgetsBinding.instance.removeObserver(this);
    _routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when the top route has been popped off, and the current route shows up.
    if (_markedForUpdate) {
      _markedForUpdate = false;
      loadData(forceUpdate: true, checkLastUpdateTime: false);
      onForceSync();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      loadData(forceUpdate: true);
    }
  }
}
