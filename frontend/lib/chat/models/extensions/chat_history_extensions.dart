import 'package:sprout/api/api.dart';

extension ChatHistoryExtensions on String {
  /// Replaces @ID patterns, standalone IDs, and streaming ID prefixes with Account Names
  String deIdentifyAccounts(List<Account> accounts) {
    if (accounts.isEmpty) return this;

    final idMap = {for (var acc in accounts) acc.id: acc.name};

    // Matches `@` mentions or word tokens containing alphanumeric chars and dashes
    final pattern = RegExp(r'`?(@[a-zA-Z0-9\-]+|\b[a-zA-Z0-9\-]+\b)`?');

    final formatted = splitMapJoin(
      pattern,
      onMatch: (Match match) {
        final fullMatch = match.group(0)!;
        final rawToken = fullMatch.replaceAll(RegExp(r'[`@]'), '');
        if (idMap.containsKey(rawToken)) {
          return "**${idMap[rawToken]}**";
        }
        // Check if rawToken is a partial prefix of ANY active account ID in memory
        final matchingAccId = idMap.keys.firstWhere(
          (accId) => accId.startsWith(rawToken) && rawToken.isNotEmpty,
          orElse: () => '',
        );
        if (matchingAccId.isNotEmpty) {
          // If the token matches the prefix of a known ID, mask it immediately with
          // a soft placeholder so raw ID characters (ACT-..., GUIDs) never bleed into the UI.
          return "**...**";
        }
        if (fullMatch.contains('@')) {
          // Hold placeholder if still actively streaming at end of string
          if (match.end == length) {
            return "**...**";
          }
          return "**Deleted Account**";
        }
        // Return plain text unaltered (normal words like "balance", "total", etc.)
        return fullMatch;
      },
      onNonMatch: (nonMatch) => nonMatch,
    );
    return formatted.replaceAll('****', '**');
  }
}
