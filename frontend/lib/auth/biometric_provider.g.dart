// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biometric_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A provider that tracks our current biometric lock/unlock state and how to do the loc/unlock

@ProviderFor(Biometrics)
final biometricsProvider = BiometricsProvider._();

/// A provider that tracks our current biometric lock/unlock state and how to do the loc/unlock
final class BiometricsProvider
    extends $NotifierProvider<Biometrics, BiometricState> {
  /// A provider that tracks our current biometric lock/unlock state and how to do the loc/unlock
  BiometricsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'biometricsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$biometricsHash();

  @$internal
  @override
  Biometrics create() => Biometrics();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BiometricState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BiometricState>(value),
    );
  }
}

String _$biometricsHash() => r'76d74241bb4e63102cac9f7f232a5281859ca5dd';

/// A provider that tracks our current biometric lock/unlock state and how to do the loc/unlock

abstract class _$Biometrics extends $Notifier<BiometricState> {
  BiometricState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BiometricState, BiometricState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<BiometricState, BiometricState>,
        BiometricState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
