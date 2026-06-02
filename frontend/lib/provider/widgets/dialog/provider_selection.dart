import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/provider/widgets/provider_icon.dart';

/// A widget that provides the ability to select from a list of providers to add accounts
class ProviderSelectionList extends StatelessWidget {
  final List<ProviderConfig> providers;
  final ValueChanged<ProviderConfig> onProviderSelected;

  const ProviderSelectionList({
    super.key,
    required this.providers,
    required this.onProviderSelected,
  });

  /// Safely extracts the Category Name header string based on the Enum variant type
  String _getCategoryTitle(ProviderSubTypeEnum? type) {
    switch (type) {
      case ProviderSubTypeEnum.bankInvestments:
        return 'Bank Investments';
      case ProviderSubTypeEnum.realEstate:
        return 'Real Estate';
      default:
        return 'Other Integrations';
    }
  }

  /// Returns an intuitive context description cleanly using your ProviderSubTypeEnum
  String _getCategoryDescription(ProviderSubTypeEnum? type) {
    switch (type) {
      case ProviderSubTypeEnum.bankInvestments:
        return 'Link your checking, savings, credit cards, and investment brokerage accounts.';
      case ProviderSubTypeEnum.realEstate:
        return 'Track home equity, asset values, and real estate market evaluations.';
      default:
        return 'Additional third-party service connections configured for Sprout.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (providers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text("No providers configured.", style: theme.textTheme.bodyLarge),
        ),
      );
    }

    final groupedProviders = groupBy<ProviderConfig, ProviderSubTypeEnum?>(
      providers,
      (provider) => provider.subType,
    );

    // Fixed, elegant layout sizing constants for the grid cards
    const double cardWidth = 140.0;
    const double cardHeight = 130.0;

    // Isolated inner builder helper for layout cards
    Widget buildGridItem(ProviderConfig provider) {
      return Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: theme.colorScheme.secondary.withOpacity(!provider.enabled ? .4 : 1),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: theme.dividerColor.withOpacity(0.15)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: !provider.enabled ? null : () => onProviderSelected(provider),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                Expanded(
                  child: Center(
                    child: FinanceProviderIcon(provider),
                  ),
                ),
                Text(
                  provider.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!provider.enabled)
                  Text(
                    "Not Configured",
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 550),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 16),
            child: Text(
              "Select a Provider",
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),

          // Flexible lets the list dynamically expand or shrink depending on card count
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              children: groupedProviders.entries.map((entry) {
                final ProviderSubTypeEnum? categoryEnum = entry.key;
                final categoryProviders = entry.value;

                final categoryTitle = _getCategoryTitle(categoryEnum);
                final categoryDescription = _getCategoryDescription(categoryEnum);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Category Header & Description Block
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            Text(
                              categoryTitle,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              categoryDescription,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: categoryProviders.map((p) {
                          return SizedBox(
                            width: cardWidth,
                            height: cardHeight,
                            child: buildGridItem(p),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
