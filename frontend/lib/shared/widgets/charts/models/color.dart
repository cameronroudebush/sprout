import 'package:flutter/material.dart';

/// A reusable color manager that handles strict color mapping
/// with a structural fallback to deterministic hash-based color generations.
class SproutChartColorResolver {
  final Map<String, Color>? colorMapping;

  static const List<Color> defaultPalette = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.cyan,
    Colors.indigo,
    Colors.lime,
    Colors.brown,
    Colors.deepPurple,
    Colors.amber,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.deepOrange,
    Colors.blueGrey,
  ];

  const SproutChartColorResolver({this.colorMapping});

  /// Resolves the correct color for an individual data entry key.
  Color resolve(String key) {
    if (colorMapping != null && colorMapping!.containsKey(key)) {
      return colorMapping![key]!;
    }
    if (key.startsWith('+')) {
      return Colors.blueGrey.shade300;
    }
    final int hash = key.hashCode;
    return defaultPalette[hash.abs() % defaultPalette.length];
  }
}
