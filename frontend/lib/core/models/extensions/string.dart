import 'dart:ui';

extension StringColorExtensions on String {
  Color toColor() {
    final hexColor = replaceAll("#", "");
    final fullHex = hexColor.length == 6 ? 'FF$hexColor' : hexColor;
    return Color(int.parse("0x$fullHex"));
  }
}
