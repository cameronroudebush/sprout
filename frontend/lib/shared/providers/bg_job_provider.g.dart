// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bg_job_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(isBackgroundJob)
final isBackgroundJobProvider = IsBackgroundJobProvider._();

final class IsBackgroundJobProvider
    extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  IsBackgroundJobProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isBackgroundJobProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isBackgroundJobHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isBackgroundJob(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isBackgroundJobHash() => r'ff8fdbea15c7d47abcddba9f6490bbea50059cee';
