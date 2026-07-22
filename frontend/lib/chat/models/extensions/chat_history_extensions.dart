import 'package:sprout/api/api.dart';

extension ChatHistoryExtensions on String {
  /// Replaces @ID patterns with the corresponding Account Name
  String deIdentifyAccounts(List<Account> accounts) {
    if (accounts.isEmpty) return this;

    String result = this;
    final pattern = RegExp(r'`?@?\b([a-zA-Z0-9\-]{10,})\b`?');

    final idMap = {for (var acc in accounts) acc.id: acc.name};

    return result.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        final id = match.group(1);
        final fullMatch = match.group(0)!;

        // If we have the account, replace it with the formatted name
        if (idMap.containsKey(id)) {
          return "**${idMap[id]}**";
        }
        // If we don't have the account, but the original text started with '@'
        else if (fullMatch.contains('@')) {
          return "**Deleted Account**";
        }
        // Otherwise, return the text exactly as it was
        else {
          return fullMatch;
        }
      },
      onNonMatch: (nonMatch) => nonMatch,
    );
  }
}
