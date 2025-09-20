import 'package:flutter/material.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/logger.dart';
import 'package:sprout/core/provider/service.locator.dart';

enum InitStatus { loading, done }

/// A notifier used to initialize all providers on startup
class InitializationNotifier extends ChangeNotifier {
  InitStatus _status = InitStatus.loading;
  InitStatus get status => _status;

  static Future<void> initializeWithNotification(Function(InitStatus) onStatusUpdate) async {
    final providersToInit = ServiceLocator.getAllProviders();
    for (final provider in providersToInit) {
      try {
        await provider.onInit();
      } catch (e) {
        LoggerService.error(e);
        if (provider is ConfigProvider) {
          onStatusUpdate(InitStatus.done);
          return;
        }
      }
    }
    onStatusUpdate(InitStatus.done);
  }

  Future<void> initialize() async {
    initializeWithNotification((status) {
      _status = status;
      notifyListeners();
    });
  }
}
