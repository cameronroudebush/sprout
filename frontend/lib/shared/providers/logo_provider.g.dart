// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod to cache and load the given image with the given data considering an authenticated API

@ProviderFor(logoImage)
const logoImageProvider = LogoImageFamily._();

/// Riverpod to cache and load the given image with the given data considering an authenticated API

final class LogoImageProvider
    extends
        $FunctionalProvider<
          AsyncValue<Uint8List>,
          Uint8List,
          FutureOr<Uint8List>
        >
    with $FutureModifier<Uint8List>, $FutureProvider<Uint8List> {
  /// Riverpod to cache and load the given image with the given data considering an authenticated API
  const LogoImageProvider._({
    required LogoImageFamily super.from,
    required ({String? faviconUrl, String? fullUrl}) super.argument,
  }) : super(
         retry: null,
         name: r'logoImageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$logoImageHash();

  @override
  String toString() {
    return r'logoImageProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Uint8List> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Uint8List> create(Ref ref) {
    final argument = this.argument as ({String? faviconUrl, String? fullUrl});
    return logoImage(
      ref,
      faviconUrl: argument.faviconUrl,
      fullUrl: argument.fullUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LogoImageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$logoImageHash() => r'c55adeb7bb380e596e5ce01cc2627d4c768bb329';

/// Riverpod to cache and load the given image with the given data considering an authenticated API

final class LogoImageFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Uint8List>,
          ({String? faviconUrl, String? fullUrl})
        > {
  const LogoImageFamily._()
    : super(
        retry: null,
        name: r'logoImageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Riverpod to cache and load the given image with the given data considering an authenticated API

  LogoImageProvider call({String? faviconUrl, String? fullUrl}) =>
      LogoImageProvider._(
        argument: (faviconUrl: faviconUrl, fullUrl: fullUrl),
        from: this,
      );

  @override
  String toString() => r'logoImageProvider';
}
