import 'package:flutter/material.dart';
import 'package:sprout/account/dialog/add_account.dart';
import 'package:sprout/category/widgets/info.dart';
import 'package:sprout/core/models/page.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/transaction-rule/widgets/rule_info.dart';

import '../../transaction-rule/transaction_rule.provider.dart';

/// Class that defines what our FAB button can do
class FABAction {
  final IconData icon;
  final String label;
  final void Function(BuildContext context) onTap;

  FABAction({required this.icon, required this.label, required this.onTap});
}

/// This widget is a reusable component that is injected within the shell to provide floating action buttons based on the current route context.
class FloatingActionButtonWidget extends StatefulWidget {
  /// How much padding to apply for the FAB
  static const padding = 80.0;

  /// The current page we are on
  final SproutPage currentPage;

  const FloatingActionButtonWidget(this.currentPage, {super.key});

  @override
  State<FloatingActionButtonWidget> createState() => _FloatingActionButtonWidgetState();
}

class _FloatingActionButtonWidgetState extends State<FloatingActionButtonWidget> {
  bool _isExpanded = false;

  /// The configuration of what button actions are available per route
  final Map<String, List<FABAction>> config = {
    // Accounts
    '/accounts': [
      FABAction(
        icon: Icons.add,
        label: 'Add Account',
        onTap: (context) => showDialog(context: context, builder: (_) => const AddAccountDialog()),
      ),
    ],
    // Transaction Rules
    '/rules': [
      FABAction(
        icon: Icons.add,
        label: 'Add New Rule',
        onTap: (context) => showDialog(context: context, builder: (_) => TransactionRuleInfo(null)),
      ),
      FABAction(
        icon: Icons.refresh,
        label: 'Manually re-run all rules',
        onTap: (context) => ServiceLocator.get<TransactionRuleProvider>().openManualRefreshDialog(context),
      ),
    ],
    // Categories
    '/categories': [
      FABAction(
        icon: Icons.add,
        label: 'Add Category',
        onTap: (context) => showDialog(context: context, builder: (_) => CategoryInfo(null)),
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    // Current route from the scaffold
    final String currentRoute = widget.currentPage.path;
    // What actions are available for our FAB
    final actions = config[currentRoute] ?? [];

    if (actions.isEmpty) return const SizedBox.shrink();

    // If we only have one action, just display the single one
    if (actions.length == 1) {
      final action = actions.first;
      return FloatingActionButton(
        heroTag: 'single_fab',
        onPressed: () => action.onTap(context),
        child: Icon(action.icon),
      );
    }

    // If we have more than one action for this route, display a speed dial to get to those options
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // The sub button actions
        ...actions.asMap().entries.map((entry) {
          int index = entry.key;
          FABAction action = entry.value;

          return AnimatedScale(
            scale: _isExpanded ? 1.0 : 0.0,
            duration: Duration(milliseconds: 200 + (index * 50)),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  // Display our text if visible
                  if (_isExpanded)
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(action.label, style: const TextStyle(fontSize: 12)),
                      ),
                    ),

                  // Display the action action button
                  FloatingActionButton.small(
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

        // Toggle button that opens the dial
        FloatingActionButton(
          heroTag: 'toggle_fab',
          onPressed: () => setState(() => _isExpanded = !_isExpanded),
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
