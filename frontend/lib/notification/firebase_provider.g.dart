// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FirebaseNotifier)
final firebaseProvider = FirebaseNotifierProvider._();

final class FirebaseNotifierProvider
    extends $NotifierProvider<FirebaseNotifier, void> {
  FirebaseNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'firebaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$firebaseNotifierHash();

  @$internal
  @override
  FirebaseNotifier create() => FirebaseNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$firebaseNotifierHash() => r'34db969b26e0a6907731fe83c8c3654295763837';

abstract class _$FirebaseNotifier extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<void, void>, void, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
