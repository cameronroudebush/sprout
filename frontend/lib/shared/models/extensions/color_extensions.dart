import 'dart:ui';

extension ColorExtensions on Color {
  /// Converts the given color to it's hex represented alue
  String toHex() => '#${value.toRadixString(16).padLeft(8, '0')}';
}
