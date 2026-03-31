import 'package:flutter/material.dart';

/// A class that extends text editing to allow us to control using @ACCOUNT to have a more modern display
class MentionController extends TextEditingController {
  final Map<String, String> idToNameMap;

  MentionController({required this.idToNameMap});

  @override
  set selection(TextSelection newSelection) {
    // Only apply logic if the selection is a collapsed cursor and we have existing text
    if (!newSelection.isCollapsed || text.isEmpty) {
      super.selection = newSelection;
      return;
    }

    final pattern = RegExp(r'@(\S+)');
    final matches = pattern.allMatches(text);

    for (final match in matches) {
      final id = match.group(1);

      if (idToNameMap.containsKey(id)) {
        // Check if the cursor is attempting to land inside the @id
        if (newSelection.baseOffset > match.start && newSelection.baseOffset < match.end) {
          final isMovingBackward = newSelection.baseOffset < selection.baseOffset;

          if (isMovingBackward) {
            super.selection = TextSelection.collapsed(offset: match.start);
          } else {
            super.selection = TextSelection.collapsed(offset: match.end);
          }
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
