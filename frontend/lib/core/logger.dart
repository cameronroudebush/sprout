import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// A service used to log useful messages
class LoggerService {
  static final Logger _logger = kIsWeb
      ? (kDebugMode ? Logger(printer: SimplePrinter(printTime: true, colors: true)) : Logger(level: Level.off))
      : Logger(
          filter: ProductionFilter(), // Show important logs
          printer: PrettyPrinter(methodCount: 2, errorMethodCount: 8, lineLength: 120, colors: true, printTime: true),
        );

  static void info(dynamic message) {
    _logger.i(message);
  }

  static void debug(dynamic message) {
    _logger.d(message);
  }

  static void warning(dynamic message) {
    _logger.w(message);
  }

  static void error(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
