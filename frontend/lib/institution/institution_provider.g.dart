// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'institution_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns the authenticated API client instance for institutions

@ProviderFor(institutionApi)
final institutionApiProvider = InstitutionApiProvider._();

/// Returns the authenticated API client instance for institutions

final class InstitutionApiProvider extends $FunctionalProvider<
        AsyncValue<InstitutionApi>, InstitutionApi, FutureOr<InstitutionApi>>
    with $FutureModifier<InstitutionApi>, $FutureProvider<InstitutionApi> {
  /// Returns the authenticated API client instance for institutions
  InstitutionApiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'institutionApiProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$institutionApiHash();

  @$internal
  @override
  $FutureProviderElement<InstitutionApi> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<InstitutionApi> create(Ref ref) {
    return institutionApi(ref);
  }
}

String _$institutionApiHash() => r'd2e89aeb2a88285b123edc09a62520e675f662ea';

@ProviderFor(Institutions)
final institutionsProvider = InstitutionsProvider._();

final class InstitutionsProvider extends $NotifierProvider<Institutions, void> {
  InstitutionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'institutionsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$institutionsHash();

  @$internal
  @override
  Institutions create() => Institutions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$institutionsHash() => r'16c7e276b479c7ab3fecebf635cc64b610e7c245';

abstract class _$Institutions extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<void, void>, void, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
