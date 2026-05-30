import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'splash_time_provider.g.dart';

@Riverpod(keepAlive: true)
class SproutSplashManager extends _$SproutSplashManager {
  // We use DateTime? to keep track of the last time the splash was shown
  DateTime? _lastShownTime;

  @override
  FutureOr<bool> build() async {
    final now = DateTime.now();

    // If it's been less than 15 minutes since the last show, bypass the 3s delay
    if (_lastShownTime != null && now.difference(_lastShownTime!) < const Duration(minutes: 15)) {
      return false;
    }

    _lastShownTime = now;

    // Hold the loading screen up for at least 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    return false;
  }
}
