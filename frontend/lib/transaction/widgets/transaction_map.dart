import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre/maplibre.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/user/user_config_provider.dart' show userConfigProvider;

/// A widget intended to display where a transaction occurred in the world, assuming we have the data
class TransactionMapWidget extends ConsumerWidget {
  /// Point Marker location
  final double latitude;

  /// Point Marker location
  final double longitude;

  /// Control whether the user can scroll, drag, zoom, or rotate the map.
  final bool isInteractive;

  const TransactionMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.isInteractive = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final secureConfig = ref.watch(secureConfigProvider).value;
    final isDarkMode = ref.watch(userConfigProvider.notifier).isDarkMode();
    if (secureConfig == null) return const SizedBox.shrink();
    final styleUrl = isDarkMode ? secureConfig.tiles.dark : secureConfig.tiles.light;

    return MapLibreMap(
      options: MapOptions(
          initStyle: styleUrl,
          initCenter: Geographic(lat: latitude, lon: longitude),
          initZoom: 14.0,
          maxPitch: 0,
          gestures: isInteractive ? MapGestures.all() : MapGestures.none()),
      children: [
        SourceAttribution(
          showMapLibre: true,
          keepExpanded: false,
        ),
        WidgetLayer(
          allowInteraction: false,
          markers: [
            Marker(
              point: Geographic(lat: latitude, lon: longitude),
              size: const Size(40, 40),
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
