// import 'package:flutter/material.dart';

// /// A widget that displays a set of tabs that remain visible at the
// /// top of the screen while the user scrolls through content.
// class StickyTabsView extends StatefulWidget {
//   const StickyTabsView({
//     super.key,
//     required this.tabs,
//     required this.tabContent,
//   });

//   /// The list of Tab widgets to display.
//   final List<Tab> tabs;

//   /// The list of content widgets corresponding to each tab.
//   /// The order and length must match the [tabs] list.
//   final List<Widget> tabContent;

//   @override
//   State<StickyTabsView> createState() => _StickyTabsViewState();
// }

// class _StickyTabsViewState extends State<StickyTabsView>
//     with SingleTickerProviderStateMixin {
//   late final TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: widget.tabs.length, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // The DefaultTabController coordinates the TabBar and TabBarView.
//       body: DefaultTabController(
//         length: widget.tabs.length,
//         child: CustomScrollView(
//           slivers: <Widget>[
//             // The SliverAppBar provides a title that can optionally scroll
//             // away. We are keeping it simple here.
//             const SliverAppBar(
//               title: Text('Sticky Tabs Example'),
//               floating: true, // The app bar will be visible as soon as you scroll up
//               pinned: false,
//             ),
//             // The SliverPersistentHeader makes the TabBar stick to the top.
//             SliverPersistentHeader(
//               delegate: _StickyTabsDelegate(
//                 tabBar: TabBar(
//                   controller: _tabController,
//                   tabs: widget.tabs,
//                 ),
//               ),
//               pinned: true, // This is what makes the header "stick".
//             ),
//             // The content of the tabs.
//             SliverFillRemaining(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: widget.tabContent,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// A custom delegate for creating a persistent header, in this case, the TabBar.
// class _StickyTabsDelegate extends SliverPersistentHeaderDelegate {
//   const _StickyTabsDelegate({required this.tabBar});

//   final TabBar tabBar;

//   // The maximum height of the header when fully expanded.
//   @override
//   double get maxExtent => tabBar.preferredSize.height;

//   // The minimum height of the header when scrolled up.
//   @override
//   double get minExtent => tabBar.preferredSize.height;

//   // Builds the content of the header.
//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     // A container is used to provide a background color.
//     return Container(
//       color: Theme.of(context).scaffoldBackgroundColor,
//       child: tabBar,
//     );
//   }

//   // Determines if the header should be rebuilt.
//   @override
//   bool shouldRebuild(_StickyTabsDelegate oldDelegate) {
//     return tabBar != oldDelegate.tabBar;
//   }
// }


// // --- EXAMPLE USAGE ---
// // You can use the StickyTabsView widget like this in your app.

// class ExamplePage extends StatelessWidget {
//   const ExamplePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // 1. Define your tabs
//     final myTabs = <Tab>[
//       const Tab(icon: Icon(Icons.home), text: 'Home'),
//       const Tab(icon: Icon(Icons.explore), text: 'Explore'),
//       const Tab(icon: Icon(Icons.settings), text: 'Settings'),
//     ];

//     // 2. Define the content for each tab
//     final myTabContent = <Widget>[
//       _buildTabContent("Home Content"),
//       _buildTabContent("Explore Content"),
//       _buildTabContent("Settings Content"),
//     ];
    
//     // 3. Pass them to the widget
//     return StickyTabsView(
//       tabs: myTabs,
//       tabContent: myTabContent,
//     );
//   }

//   // Helper method to create scrollable content for a tab.
//   Widget _buildTabContent(String title) {
//     return ListView.builder(
//       // Important: The physics should be NeverScrollableScrollPhysics
//       // because the CustomScrollView is handling the scrolling.
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: 50,
//       itemBuilder: (context, index) => ListTile(
//         title: Text('$title Item ${index + 1}'),
//       ),
//     );
//   }
// }