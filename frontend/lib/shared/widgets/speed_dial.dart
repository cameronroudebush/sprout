import 'package:flutter/material.dart';

/// Class that defines what our FAB button can do
class FABAction {
  final IconData icon;
  final String label;
  final void Function(BuildContext context) onTap;

  FABAction({required this.icon, required this.label, required this.onTap});
}

/// This widget is a reusable component that is injected within the shell to provide floating action buttons based on the current route context.
///   It supports a dial in the event you have more than one [FABAction].
class SproutSpeedDial extends StatefulWidget {
  /// The list of actions to display
  final List<FABAction> actions;

  const SproutSpeedDial({super.key, required this.actions});

  @override
  State<SproutSpeedDial> createState() => _SproutSpeedDialState();
}

class _SproutSpeedDialState extends State<SproutSpeedDial> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.actions.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    // Single action: standard FAB
    if (widget.actions.length == 1) {
      final action = widget.actions.first;
      return FloatingActionButton(
        heroTag: 'single_fab',
        backgroundColor: theme.colorScheme.secondary,
        onPressed: () => action.onTap(context),
        child: Icon(action.icon),
      );
    }

    // Multiple actions: Speed Dial
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ...widget.actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;

          return AnimatedScale(
            scale: _isExpanded ? 1.0 : 0.0,
            duration: Duration(milliseconds: 200 + (index * 50)),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  if (_isExpanded)
                    Card(
                      elevation: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            action.label,
                            style: TextStyle(fontSize: 12, backgroundColor: theme.colorScheme.secondary),
                          ),
                        ),
                      ),
                    ),
                  FloatingActionButton.small(
                    backgroundColor: theme.colorScheme.secondary,
                    heroTag: 'sub_$index',
                    onPressed: () {
                      action.onTap(context);
                      setState(() => _isExpanded = false);
                    },
                    child: Icon(action.icon),
                  ),
                ],
              ),
            ),
          );
        }),

        // Main Toggle Button
        FloatingActionButton(
          heroTag: 'toggle_fab',
          onPressed: () => setState(() => _isExpanded = !_isExpanded),
          backgroundColor: theme.colorScheme.secondary,
          child: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(_isExpanded ? Icons.add : Icons.menu_open),
          ),
        ),
      ],
    );
  }
}
