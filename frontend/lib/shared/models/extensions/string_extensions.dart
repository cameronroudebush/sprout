import 'dart:ui';

extension StringCasingExtension on String {
  String get toCapitalized => length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String get toTitleCase => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized).join(' ');
  String get snakeCase {
    String snakeCase = replaceAll(
      RegExp(r'\s'),
      '',
    ).replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match.group(0)!.toLowerCase()}');
    if (snakeCase.startsWith('_')) snakeCase = snakeCase.substring(1);
    return snakeCase;
  }

  String get kebabCase {
    String k = replaceAll(
      RegExp(r'\s'),
      '',
    ).replaceAllMapped(RegExp(r'[A-Z]'), (match) => '-${match.group(0)!.toLowerCase()}');
    if (k.startsWith('-')) k = k.substring(1);
    return k;
  }

  /// Attempts to parse the current value as a hex code to a color for flutter
  Color toColor() {
    final hexColor = replaceAll("#", "");
    final fullHex = hexColor.length == 6 ? 'FF$hexColor' : hexColor;
    return Color(int.parse("0x$fullHex"));
  }

  /// Converts common code identifiers or raw strings into a clean, presentation-ready Title Case format.
  String get toPrettyCase {
    if (isEmpty) return '';
    String result = replaceAllMapped(
      RegExp(r'(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])'),
      (match) => ' ',
    );
    result = result.replaceAll(RegExp(r'[-_\s]+'), ' ');
    return result.trim().toTitleCase;
  }
}
