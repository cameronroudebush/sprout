// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A reusable formatter that allows you to format currencies

@ProviderFor(currencyFormatter)
final currencyFormatterProvider = CurrencyFormatterProvider._();

/// A reusable formatter that allows you to format currencies

final class CurrencyFormatterProvider extends $FunctionalProvider<
    CurrencyFormatter,
    CurrencyFormatter,
    CurrencyFormatter> with $Provider<CurrencyFormatter> {
  /// A reusable formatter that allows you to format currencies
  CurrencyFormatterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currencyFormatterProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currencyFormatterHash();

  @$internal
  @override
  $ProviderElement<CurrencyFormatter> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CurrencyFormatter create(Ref ref) {
    return currencyFormatter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CurrencyFormatter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CurrencyFormatter>(value),
    );
  }
}

String _$currencyFormatterHash() => r'9dfb2cb4639eb62ede756310be7f9f92a98155e1';
