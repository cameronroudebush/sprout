import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'setup_provider.g.dart';

/// This provide purely tracks the current step of the setup page. This helps reduce re-rendering issues losing where
///   we were in the page setup process
@riverpod
class SetupStep extends _$SetupStep {
  @override
  int build() => 0;

  void setStep(int step) {
    state = step;
  }

  void next() {
    state++;
  }

  void reset() {
    state = 0;
  }
}
