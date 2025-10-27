import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/provider/snackbar.dart';

/// A global event bus for when all data has been updated.
final _allDataUpdatedController = StreamController<void>.broadcast();

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

  /// When a the user authenticates, we use this to request our first run of data. We can also use it to later re-request bulk data.
  Future<void> updateData() async {}

  /// When a a user disconnects and we don't need our data anymore this will be called.
  Future<void> cleanupData() async {}

  /// When this provider is initialized this will be called. Note that no auth will be ready!
  Future<void> onInit() async {
    isInitialized = true;
    notifyListeners();
  }

  /// A stream that emits an event whenever all data has been updated.
  static Stream<void> get onAllDataUpdated => _allDataUpdatedController.stream;

  /// Requests all providers to refresh their data
  static Future<void> updateAllData({bool showSnackbar = false, bool async = true}) async {
    if (async) {
      await Future.wait(ServiceLocator.getAllProviders().map((e) async => await e.updateData()));
    } else {
      for (final provider in ServiceLocator.getAllProviders()) {
        await provider.updateData();
      }
    }

    if (showSnackbar) {
      SnackbarProvider.openSnackbar("Accounts refreshed");
    }
    _allDataUpdatedController.add(null);
  }
}
