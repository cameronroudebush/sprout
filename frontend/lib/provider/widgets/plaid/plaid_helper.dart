import 'package:plaid_flutter/plaid_flutter.dart';
import 'package:sprout/api/api.dart';

class PlaidSyncHelper {
  /// Exchanges a Plaid public token for an access token and links the accounts.
  /// Safe to call on both new links and re-links (will skip if publicToken is empty).
  static Future<void> exchangePublicTokenIfNeeded(
    LinkSuccess success,
    ProviderApi api, {
    String fallbackInstitutionName = "Unknown",
  }) async {
    // Standard update mode does not return a public token.
    if (success.publicToken.isEmpty) return;

    final inst = PlaidInstitutionDTO(
      name: success.metadata.institution?.name ?? fallbackInstitutionName,
      institutionId: success.metadata.institution?.id ?? "",
    );

    final accounts = success.metadata.accounts
        .map((acc) => PlaidAccountDTO(
              id: acc.id,
              name: acc.name,
              type: acc.type.toString(),
              subtype: acc.subtype.toString(),
              mask: acc.mask,
            ))
        .toList();

    final result = PlaidLinkDTO(
      publicToken: success.publicToken,
      metadata: PlaidMetadataDTO(
        institution: inst,
        accounts: accounts,
        linkSessionId: success.metadata.linkSessionId,
      ),
    );

    await api.plaidProviderControllerExchangeAndLink(result);
  }
}
