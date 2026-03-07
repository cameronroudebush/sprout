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
}
