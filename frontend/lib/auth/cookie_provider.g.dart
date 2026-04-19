// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cookie_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Generic cookie jar to persist across app restarts for usage in mobile

@ProviderFor(cookieJar)
final cookieJarProvider = CookieJarFamily._();

/// Generic cookie jar to persist across app restarts for usage in mobile

final class CookieJarProvider extends $FunctionalProvider<AsyncValue<CookieJar>,
        CookieJar, FutureOr<CookieJar>>
    with $FutureModifier<CookieJar>, $FutureProvider<CookieJar> {
  /// Generic cookie jar to persist across app restarts for usage in mobile
  CookieJarProvider._(
      {required CookieJarFamily super.from, required bool super.argument})
      : super(
          retry: null,
          name: r'cookieJarProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cookieJarHash();

  @override
  String toString() {
    return r'cookieJarProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CookieJar> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CookieJar> create(Ref ref) {
    final argument = this.argument as bool;
    return cookieJar(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CookieJarProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cookieJarHash() => r'2bdf6939aa1dc165bfd3b687f70cdb24fe35f110';

/// Generic cookie jar to persist across app restarts for usage in mobile

final class CookieJarFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CookieJar>, bool> {
  CookieJarFamily._()
      : super(
          retry: null,
          name: r'cookieJarProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  /// Generic cookie jar to persist across app restarts for usage in mobile

  CookieJarProvider call(
    bool persist,
  ) =>
      CookieJarProvider._(argument: persist, from: this);

  @override
  String toString() => r'cookieJarProvider';
}
