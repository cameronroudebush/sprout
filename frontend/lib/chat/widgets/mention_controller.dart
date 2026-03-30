import 'package:flutter/material.dart';

/// A class that extends text editing to allow us to control using @ACCOUNT to have a more modern display
class MentionController extends TextEditingController {
  final Map<String, String> idToNameMap;

  MentionController({required this.idToNameMap});

  @override
  set selection(TextSelection newSelection) {
    if (!newSelection.isCollapsed) {
      super.selection = newSelection;
      return;
    }

    // Regex to find @ followed by any non-whitespace characters
    final pattern = RegExp(r'@(\S+)');
    final matches = pattern.allMatches(text);

    for (final match in matches) {
      final id = match.group(1);

      // Only guard if this is a valid account ID
      if (idToNameMap.containsKey(id)) {
        // If cursor is anywhere from the '@' to exactly the end of the ID
        if (newSelection.baseOffset >= match.start && newSelection.baseOffset <= match.end) {
          if (match.end == text.length || text[match.end] != ' ') {
            final newText = text.replaceRange(match.end, match.end, " ");
            this.value = TextEditingValue(
              text: newText,
              selection: TextSelection.collapsed(offset: match.end + 1),
            );
            return;
          }
          super.selection = TextSelection.collapsed(offset: match.end + 1);
          return;
        }
      }
    }

    super.selection = newSelection;
  }

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final List<InlineSpan> children = [];
    final pattern = RegExp(r'@(\S+)');
    final theme = Theme.of(context);

    text.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        final id = match.group(1);

        if (idToNameMap.containsKey(id)) {
          children.add(TextSpan(
            text: '@${idToNameMap[id]}',
            style: style?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
          ));
        } else {
          children.add(TextSpan(text: match.group(0), style: style));
        }
        return '';
      },
      onNonMatch: (String text) {
        children.add(TextSpan(text: text, style: style));
        return '';
      },
    );

    return TextSpan(style: style, children: children);
  }
}
