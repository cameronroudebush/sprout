import 'package:flutter/material.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/text.dart';

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

  const ScrollableTabsWidget(this.tabNames, this.tabContent);

  @override
  State<ScrollableTabsWidget> createState() => _ScrollableTabsWidgetState();
}

class _ScrollableTabsWidgetState extends State<ScrollableTabsWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Tell Flutter to keep this page's state

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: widget.tabNames.length,
      child: Column(
        children: [
          // Render the tab names
          TabBar(
            labelPadding: EdgeInsets.zero,
            tabs: widget.tabNames.map((tab) {
              return Padding(
                padding: EdgeInsetsGeometry.symmetric(vertical: 12),
                child: TextWidget(
                  text: tab.toTitleCase,
                  referenceSize: 1.15,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ),
          // Render the tab content for the current tab
          Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(), // Disable animation
              children: widget.tabContent,
            ),
          ),
        ],
      ),
    );
  }
}
