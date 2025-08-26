import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/core/widgets/nav_scaffold.dart';

/// This class defines the shell that wraps all pages that are displayed for sprout
class SproutAppShell extends StatefulWidget {
  final VoidCallback? onSetupSuccess;
  const SproutAppShell({super.key, this.onSetupSuccess});

  @override
  State<SproutAppShell> createState() => _SproutAppShellState();
}

class _SproutAppShellState extends State<SproutAppShell> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    BaseProvider.updateAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfigProvider>(
      builder: (context, configProvider, child) {
        if (_scrollController.positions.isNotEmpty) _scrollController.jumpTo(0);
        return SproutNavScaffold();
      },
    );
  }
}
