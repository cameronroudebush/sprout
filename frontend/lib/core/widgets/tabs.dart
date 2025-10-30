import 'package:flutter/material.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/layout.dart';

/// A reusable widget that displays a set of scrollable tabs.
///
/// This component requires a list of tab titles and a corresponding list of
/// content widgets. It handles the state and synchronization between the
/// TabBar and the TabBarView.
class ScrollableTabsWidget extends StatefulWidget {
  /// List of names to display for the tabs
  final List<String> tabNames;

  /// List of widgets to display for the tabs
  final List<Widget> tabContent;

  /// The index of the tab to be selected. Can be changed externally.
  final int initialIndex;

  const ScrollableTabsWidget(this.tabNames, this.tabContent, {super.key, this.initialIndex = 0})
    : assert(initialIndex >= 0 && initialIndex < tabNames.length);

  @override
  State<ScrollableTabsWidget> createState() => _ScrollableTabsWidgetState();
}

class _ScrollableTabsWidgetState extends State<ScrollableTabsWidget>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final TabController _tabController;

  @override
  bool get wantKeepAlive => true; // Tell Flutter to keep this page's state

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabNames.length, vsync: this, initialIndex: widget.initialIndex);
  }

  @override
  void didUpdateWidget(ScrollableTabsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the initialIndex passed from the parent changes, animate to the new tab.
    if (widget.initialIndex != oldWidget.initialIndex) {
      _tabController.animateTo(widget.initialIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SproutLayoutBuilder((isDesktop, context, constraints) {
      return Column(
        children: [
          TabBar(
            controller: _tabController,
            labelPadding: EdgeInsets.zero,
            tabs: widget.tabNames.map((tab) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  tab.toTitleCase,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: isDesktop ? 16 : 14),
                ),
              );
            }).toList(),
          ),
          // Render the tab content for the current tab
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(), // Disable swiping
              children: widget.tabContent,
            ),
          ),
        ],
      );
    });
  }
}
