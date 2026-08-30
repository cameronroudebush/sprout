import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/transaction/widgets/transaction_map.dart';

class TransactionLocationCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionLocationCard({super.key, required this.transaction});

  /// Single source of truth for location availability
  static bool hasLocationData(Transaction transaction) {
    final locationData = transaction.extra?.location;
    final lat = locationData?.lat?.toDouble();
    final lon = locationData?.lon?.toDouble();
    final hasAddress = [
      locationData?.address,
      locationData?.city,
      locationData?.region,
    ].any((part) => part != null && part.trim().isNotEmpty);

    return (lat != null && lon != null) || hasAddress;
  }

  @override
  Widget build(BuildContext context) {
    if (!hasLocationData(transaction)) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final locationData = transaction.extra?.location;
    final lat = locationData?.lat?.toDouble();
    final lon = locationData?.lon?.toDouble();
    final hasCoordinates = lat != null && lon != null;

    final address = "${locationData?.address ?? ''} ${locationData?.city ?? ''}".trim();

    return SproutCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Location", style: theme.textTheme.titleSmall),
            if (address.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                child: Text(
                  address,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            if (hasCoordinates) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: TransactionMapWidget(latitude: lat, longitude: lon),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
