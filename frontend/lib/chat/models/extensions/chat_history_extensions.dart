import 'package:sprout/api/api.dart';

extension ChatHistoryExtensions on String {
  /// Replaces @ID patterns with the corresponding Account Name
  String deIdentifyAccounts(List<Account> accounts) {
    if (accounts.isEmpty) return this;

    String result = this;
    final pattern = RegExp(r'@?\b([a-zA-Z0-9\-]{10,})\b');

    final idMap = {for (var acc in accounts) acc.id: acc.name};

    return result.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        final id = match.group(1);
        return idMap.containsKey(id) ? "**${idMap[id]}**" : match.group(0)!;
      },
      onNonMatch: (nonMatch) => nonMatch,
    );
  }
}
