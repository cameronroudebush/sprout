import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/config/config_provider.dart';

part 'logo_provider.g.dart';

/// Provides the institutions icon
@Riverpod(keepAlive: true)
Future<List<String>> institutionIcon(Ref ref, Institution institution, double size) async {
  final clientId = ref.watch(secureConfigProvider).value?.brandFetchClientId;
  if (clientId == null) return [];

  final host = Uri.parse(institution.url).host;
  final domain = host.replaceFirst(RegExp(r'^www\.'), '');
  final d = size * 2;
  final type = institution.iconType.value;

  return [
    "https://cdn.brandfetch.io/domain/$domain/fallback/404/h/$d/w/$d/$type?c=$clientId",
  ];
}

/// Provides the institutions full logo
@Riverpod(keepAlive: true)
Future<List<String>> institutionLogo(Ref ref, Institution institution, double width) async {
  final clientId = ref.watch(secureConfigProvider).value?.brandFetchClientId;
  if (clientId == null) return [];

  final host = Uri.parse(institution.url).host;
  final domain = host.replaceFirst(RegExp(r'^www\.'), '');
  final d = width * 2;
  return [
    "https://cdn.brandfetch.io/domain/$domain/fallback/404/w/$d/logo?c=$clientId",
  ];
}

/// Provides the ticker icon
@Riverpod(keepAlive: true)
Future<List<String>> tickerIcon(Ref ref, Holding holding, Institution institution, double size) async {
  final clientId = ref.watch(secureConfigProvider).value?.brandFetchClientId;
  if (clientId == null) return [];

  final host = Uri.parse(institution.url).host;
  final domain = host.replaceFirst(RegExp(r'^www\.'), '');
  final d = size * 2;

  return [
    "https://cdn.brandfetch.io/ticker/${holding.symbol}/fallback/404/h/$d/w/$d/icon?c=$clientId",
    "https://cdn.brandfetch.io/domain/$domain/fallback/404/h/$d/w/$d/icon?c=$clientId",
  ];
}

/// Provides the account provider icon
@Riverpod(keepAlive: true)
Future<List<String>> providerIcon(Ref ref, ProviderConfig provider, double size) async {
  final clientId = ref.watch(secureConfigProvider).value?.brandFetchClientId;
  if (clientId == null) return [];

  final host = Uri.parse(provider.url).host;
  final domain = host.replaceFirst(RegExp(r'^www\.'), '');
  final d = size * 2;

  return [
    "https://cdn.brandfetch.io/domain/$domain/fallback/404/w/$d/icon?c=$clientId",
  ];
}
