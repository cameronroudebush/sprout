// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the institutions icon

@ProviderFor(institutionIcon)
final institutionIconProvider = InstitutionIconFamily._();

/// Provides the institutions icon

final class InstitutionIconProvider extends $FunctionalProvider<
        AsyncValue<List<String>>, List<String>, FutureOr<List<String>>>
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Provides the institutions icon
  InstitutionIconProvider._(
      {required InstitutionIconFamily super.from,
      required (
        Institution,
        double,
      )
          super.argument})
      : super(
          retry: null,
          name: r'institutionIconProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$institutionIconHash();

  @override
  String toString() {
    return r'institutionIconProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    final argument = this.argument as (
      Institution,
      double,
    );
    return institutionIcon(
      ref,
      argument.$1,
      argument.$2,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is InstitutionIconProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$institutionIconHash() => r'9687f1186262e300c035523e53c3c182c8a5f3d1';

/// Provides the institutions icon

final class InstitutionIconFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<List<String>>,
            (
              Institution,
              double,
            )> {
  InstitutionIconFamily._()
      : super(
          retry: null,
          name: r'institutionIconProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  /// Provides the institutions icon

  InstitutionIconProvider call(
    Institution institution,
    double size,
  ) =>
      InstitutionIconProvider._(argument: (
        institution,
        size,
      ), from: this);

  @override
  String toString() => r'institutionIconProvider';
}

/// Provides the institutions full logo

@ProviderFor(institutionLogo)
final institutionLogoProvider = InstitutionLogoFamily._();

/// Provides the institutions full logo

final class InstitutionLogoProvider extends $FunctionalProvider<
        AsyncValue<List<String>>, List<String>, FutureOr<List<String>>>
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Provides the institutions full logo
  InstitutionLogoProvider._(
      {required InstitutionLogoFamily super.from,
      required (
        Institution,
        double,
      )
          super.argument})
      : super(
          retry: null,
          name: r'institutionLogoProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$institutionLogoHash();

  @override
  String toString() {
    return r'institutionLogoProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    final argument = this.argument as (
      Institution,
      double,
    );
    return institutionLogo(
      ref,
      argument.$1,
      argument.$2,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is InstitutionLogoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$institutionLogoHash() => r'1750a97962b8ddb92726b72180f0222243a33330';

/// Provides the institutions full logo

final class InstitutionLogoFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<List<String>>,
            (
              Institution,
              double,
            )> {
  InstitutionLogoFamily._()
      : super(
          retry: null,
          name: r'institutionLogoProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  /// Provides the institutions full logo

  InstitutionLogoProvider call(
    Institution institution,
    double width,
  ) =>
      InstitutionLogoProvider._(argument: (
        institution,
        width,
      ), from: this);

  @override
  String toString() => r'institutionLogoProvider';
}

/// Provides the ticker icon

@ProviderFor(tickerIcon)
final tickerIconProvider = TickerIconFamily._();

/// Provides the ticker icon

final class TickerIconProvider extends $FunctionalProvider<
        AsyncValue<List<String>>, List<String>, FutureOr<List<String>>>
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Provides the ticker icon
  TickerIconProvider._(
      {required TickerIconFamily super.from,
      required (
        Holding,
        Institution,
        double,
      )
          super.argument})
      : super(
          retry: null,
          name: r'tickerIconProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tickerIconHash();

  @override
  String toString() {
    return r'tickerIconProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    final argument = this.argument as (
      Holding,
      Institution,
      double,
    );
    return tickerIcon(
      ref,
      argument.$1,
      argument.$2,
      argument.$3,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TickerIconProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tickerIconHash() => r'9f536b27b771a6a2fa55ae43fa99886f16eb7898';

/// Provides the ticker icon

final class TickerIconFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<List<String>>,
            (
              Holding,
              Institution,
              double,
            )> {
  TickerIconFamily._()
      : super(
          retry: null,
          name: r'tickerIconProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  /// Provides the ticker icon

  TickerIconProvider call(
    Holding holding,
    Institution institution,
    double size,
  ) =>
      TickerIconProvider._(argument: (
        holding,
        institution,
        size,
      ), from: this);

  @override
  String toString() => r'tickerIconProvider';
}

/// Provides the account provider icon

@ProviderFor(providerIcon)
final providerIconProvider = ProviderIconFamily._();

/// Provides the account provider icon

final class ProviderIconProvider extends $FunctionalProvider<
        AsyncValue<List<String>>, List<String>, FutureOr<List<String>>>
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Provides the account provider icon
  ProviderIconProvider._(
      {required ProviderIconFamily super.from,
      required (
        ProviderConfig,
        double,
      )
          super.argument})
      : super(
          retry: null,
          name: r'providerIconProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$providerIconHash();

  @override
  String toString() {
    return r'providerIconProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    final argument = this.argument as (
      ProviderConfig,
      double,
    );
    return providerIcon(
      ref,
      argument.$1,
      argument.$2,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProviderIconProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$providerIconHash() => r'43f3f09e186465d5517209dd130b82d89002defc';

/// Provides the account provider icon

final class ProviderIconFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<List<String>>,
            (
              ProviderConfig,
              double,
            )> {
  ProviderIconFamily._()
      : super(
          retry: null,
          name: r'providerIconProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  /// Provides the account provider icon

  ProviderIconProvider call(
    ProviderConfig provider,
    double size,
  ) =>
      ProviderIconProvider._(argument: (
        provider,
        size,
      ), from: this);

  @override
  String toString() => r'providerIconProvider';
}

/// Provides an icon for an arbitrary website URL

@ProviderFor(websiteIcon)
final websiteIconProvider = WebsiteIconFamily._();

/// Provides an icon for an arbitrary website URL

final class WebsiteIconProvider extends $FunctionalProvider<
        AsyncValue<List<String>>, List<String>, FutureOr<List<String>>>
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Provides an icon for an arbitrary website URL
  WebsiteIconProvider._(
      {required WebsiteIconFamily super.from,
      required (
        String,
        double,
      )
          super.argument})
      : super(
          retry: null,
          name: r'websiteIconProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$websiteIconHash();

  @override
  String toString() {
    return r'websiteIconProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    final argument = this.argument as (
      String,
      double,
    );
    return websiteIcon(
      ref,
      argument.$1,
      argument.$2,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WebsiteIconProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$websiteIconHash() => r'9ee68a26ea5b5c39078f6c747168035c032639f4';

/// Provides an icon for an arbitrary website URL

final class WebsiteIconFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<List<String>>,
            (
              String,
              double,
            )> {
  WebsiteIconFamily._()
      : super(
          retry: null,
          name: r'websiteIconProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  /// Provides an icon for an arbitrary website URL

  WebsiteIconProvider call(
    String websiteUrl,
    double size,
  ) =>
      WebsiteIconProvider._(argument: (
        websiteUrl,
        size,
      ), from: this);

  @override
  String toString() => r'websiteIconProvider';
}
