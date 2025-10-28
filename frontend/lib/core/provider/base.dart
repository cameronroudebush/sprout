import 'dart:async';

import 'package:flutter/material.dart';

/// This class provides some basic capability that is required by our data driven providers
abstract class BaseProvider<T> with ChangeNotifier {
  /// The reference to the API this provider uses to get data from the backend.
  final T api;

  /// Tracks our disposal state to handle notification listener errors.
  bool _disposed = false;

  /// Used to track if we are loading data or not from [updateData]
  bool isLoading = true;

  bool isInitialized = false;

  BaseProvider(this.api);

  @override
  void dispose() {
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

  /// When something occurs that will force
  Future<void> onForceResync() async {}

  /// Fired after the login occurs for a user.
  ///   You should not use this to request large amounts of data,
  ///   only small pieces used across the app.
  Future<void> postLogin() async {}

  /// When a a user disconnects and we don't need our data anymore this will be called.
  Future<void> cleanupData() async {}

  /// When this provider is initialized this will be called. Note that no authentication will be ready!
  Future<void> onInit() async {
    isInitialized = true;
    notifyListeners();
  }
}
