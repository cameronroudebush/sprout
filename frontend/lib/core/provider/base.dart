import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/provider/sse.dart';

/// This class provides some basic capability that is required by our data driven providers
abstract class BaseProvider<T> with ChangeNotifier {
  /// The reference to the API this provider uses to get data from the backend.
  final T api;

  /// Tracks our disposal state to handle notification listener errors.
  bool _disposed = false;

  /// Used to track if we are loading data so the interfaces know this provider isn't ready.
  bool isLoading = true;

  /// Tracks if this provider has been initialized.
  bool isInitialized = false;

  /// A subscription for the SSE stream that we keep so we can dispose of it.
  StreamSubscription<SSEData>? _sseStreamSubscription;

  BaseProvider(this.api);

  @override
  void dispose() {
    _sseStreamSubscription?.cancel();
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  /// Sets the loading status to the given bool and notifies any listeners of this provider
  void setLoadingStatus(bool isLoading) {
    this.isLoading = isLoading;
    notifyListeners();
  }

  /// Populates the given property based on an api call only if the value has changed. If the value has changed, we will notify.
  Future<Z?> populateAndSetIfChanged<Z>(Future<Z?> Function() apiCall, Z? currentValue, Function(Z?) setter) async {
    final newValue = await apiCall();
    if (newValue != currentValue) {
      setLoadingStatus(true);
      setter(newValue);
      setLoadingStatus(false);
      return newValue;
    } else {
      return currentValue;
    }
  }

  /// This method will be called when an [SSEData] event comes in from the backend. You can use this to grab relevant fields.
  Future<void> onSSE(SSEData data) async {}

  /// Fired after the login occurs for a user.
  ///   You should not use this to request large amounts of data,
  ///   only small pieces used across the app.
  Future<void> postLogin() async {}

  /// When a a user disconnects and we don't need our data anymore this will be called.
  Future<void> cleanupData() async {}

  /// When this provider is initialized this will be called. Note that no authentication will be ready!
  Future<void> onInit() async {
    _sseStreamSubscription = ServiceLocator.get<SSEProvider>().onSSEEvent.listen((data) => onSSE(data));
    isInitialized = true;
    notifyListeners();
  }
}
