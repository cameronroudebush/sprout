import 'dart:ui';

extension ColorExtensions on Color {
  /// Converts the given color to it's hex represented value
  String toHex() => '#${value.toRadixString(16).padLeft(8, '0')}';

  /// Same as [toHex] but ignores alpha channel
  String toHexIgnoreAlpha() => '#${value.toRadixString(16).substring(2, 8).padLeft(6, '0')}';
}
