// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setup_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// This provide purely tracks the current step of the setup page. This helps reduce re-rendering issues losing where
///   we were in the page setup process

@ProviderFor(SetupStep)
final setupStepProvider = SetupStepProvider._();

/// This provide purely tracks the current step of the setup page. This helps reduce re-rendering issues losing where
///   we were in the page setup process
final class SetupStepProvider extends $NotifierProvider<SetupStep, int> {
  /// This provide purely tracks the current step of the setup page. This helps reduce re-rendering issues losing where
  ///   we were in the page setup process
  SetupStepProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'setupStepProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$setupStepHash();

  @$internal
  @override
  SetupStep create() => SetupStep();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$setupStepHash() => r'1db5427e9a47ed06e0cf61e4652b4d96e9255758';

/// This provide purely tracks the current step of the setup page. This helps reduce re-rendering issues losing where
///   we were in the page setup process

abstract class _$SetupStep extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element = ref.element
        as $ClassProviderElement<AnyNotifier<int, int>, int, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
