import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/provider/widgets/provider_logo.dart';

/// A widget that provides the ability to select from a list of providers to add accounts
class ProviderSelectionList extends StatelessWidget {
  final List<ProviderConfig> providers;
  final ValueChanged<ProviderConfig> onProviderSelected;

  const ProviderSelectionList({
    super.key,
    required this.providers,
    required this.onProviderSelected,
  });

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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text("Select a Provider", style: theme.textTheme.titleMedium),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 500, maxWidth: 600),
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: providers.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final provider = providers[index];
              return Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: theme.dividerColor.withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () => onProviderSelected(provider),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 8,
                      children: [
                        // Big Icon
                        Expanded(
                          child: Center(
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: FinanceProviderLogoWidget(provider),
                            ),
                          ),
                        ),
                        // Small text
                        Text(
                          provider.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
