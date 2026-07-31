import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/shared/providers/logger_provider.dart';

extension SproutAsyncValueX<T> on AsyncValue<T> {
  /// A standardized `.when` that automatically handles Sprout's default loading, error, and empty UIs.
  ///
  /// * [emptyCondition]: Optional. Override the default empty check.
  /// * [emptyWidget]: The custom widget to show if data is empty. (Auto-centered).
  /// * [loadingText]: Optional label to display beneath the loading spinner.
  /// * [customErrorMessage]: Custom text to display on error instead of the raw exception.
  /// * [expanded]: Set to true if this widget is inside a Column/Row and needs to stretch.
  Widget whenDefault({
    required Widget Function(T data) data,
    bool Function(T data)? emptyCondition,
    Widget? emptyWidget,
    String? loadingText,
    String? customErrorMessage,
    bool expanded = false,
  }) {
    Widget buildLoading() => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (loadingText != null) ...[
                  const SizedBox(height: 12.0),
                  Text(
                    loadingText,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );

    Widget buildError(Object err) {
      final cleanMessage = err.toString().split('\n').first;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(customErrorMessage ?? cleanMessage),
        ),
      );
    }

    Widget buildEmpty() => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: emptyWidget ?? const Text("No data available"),
          ),
        );

    return when(
      data: (d) {
        bool isDataEmpty = false;
        if (emptyCondition != null) {
          isDataEmpty = emptyCondition(d);
        } else {
          if (d == null) {
            isDataEmpty = true;
          } else if (d is Iterable) {
            isDataEmpty = d.isEmpty;
          } else if (d is Map) {
            isDataEmpty = d.isEmpty;
          } else if (d is String) {
            isDataEmpty = d.isEmpty;
          }
        }
        if (isDataEmpty) {
          return expanded ? Expanded(child: buildEmpty()) : buildEmpty();
        }

        return data(d);
      },
      loading: () => expanded ? Expanded(child: buildLoading()) : buildLoading(),
      error: (err, stack) {
        LoggerProvider.error(
          'SproutAsyncValueX caught an error',
          error: err,
          stackTrace: stack,
        );
        return expanded ? Expanded(child: buildError(err)) : buildError(err);
      },
    );
  }
}
