import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/api/base_api.dart';
import 'package:sprout/shared/providers/provider_helpers.dart';

part 'provider_provider.g.dart';

/// Returns the authenticated API for the provider client
@Riverpod(keepAlive: true)
Future<ProviderApi> providerApi(Ref ref) async {
  final client = await ref.watch(baseAuthenticatedClientProvider.future);
  return ProviderApi(client);
}

@Riverpod(retry: riverpodRetry)
Future<List<Account>?> simpleFinAccounts(Ref ref) async {
  final api = ref.watch(providerApiProvider).value;
  if (api == null) {
    return [];
  }
  return await api.simpleFinProviderControllerGetAccounts();
}

@Riverpod(retry: riverpodRetry)
Future<List<ProviderConfig>?> providerConfig(Ref ref) async {
  final api = ref.watch(providerApiProvider).value;
  if (api == null) {
    return [];
  }
  return await api.baseProviderControllerGetConfig();
}
