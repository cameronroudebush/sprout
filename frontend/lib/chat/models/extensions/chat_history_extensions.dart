import 'package:sprout/api/api.dart';

extension ChatHistoryExtensions on String {
  /// Replaces @ID patterns with the corresponding Account Name
  String deIdentifyAccounts(List<Account> accounts) {
    if (accounts.isEmpty) return this;

    String result = this;
    final pattern = RegExp(r'`?@?\b([a-zA-Z0-9\-]{10,})\b`?');

    final idMap = {for (var acc in accounts) acc.id: acc.name};

    final formatted = result.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        final id = match.group(1)!;
        final fullMatch = match.group(0)!;

        // If we have the account, replace it with the formatted name
        if (idMap.containsKey(id)) {
          return "**${idMap[id]}**";
        }
        // If it starts with '@', check if it's currently streaming in as a partial match of a real account ID
        else if (fullMatch.contains('@')) {
          final isPartialMatch = idMap.keys.any((accId) => accId.startsWith(id));
          final isAtEndOfString = match.end == result.length;

          // If it matches the prefix of an existing account ID and is at the end of the stream, wait for more tokens
          if (isPartialMatch && isAtEndOfString) {
            return fullMatch;
          }

          return "**Deleted Account**";
        }
        // Otherwise, return the text exactly as it was
        else {
          return fullMatch;
        }
      },
      onNonMatch: (nonMatch) => nonMatch,
    );

    // Collapses quadrupled asterisks (****) down to doubled asterisks (**)
    return formatted.replaceAll('****', '**');
  }
}
