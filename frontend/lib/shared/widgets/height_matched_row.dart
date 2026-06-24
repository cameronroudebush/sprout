import 'package:flutter/material.dart';

/// A reusable widget that allows the height of one widget to match the height of the other, dynamically
class HeightMatchedRow extends StatefulWidget {
  /// The widget whose height dictates the row
  final Widget leadChild;

  /// The widget that will be forced to match [leadChild]'s height
  final Widget followingChild;

  final int leadFlex;
  final int followingFlex;
  final double gap;
  final CrossAxisAlignment crossAxisAlignment;

  const HeightMatchedRow({
    super.key,
    required this.leadChild,
    required this.followingChild,
    this.leadFlex = 1,
    this.followingFlex = 1,
    this.gap = 0.0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  State<HeightMatchedRow> createState() => _HeightMatchedRowState();
}

class _HeightMatchedRowState extends State<HeightMatchedRow> {
  final GlobalKey _leadKey = GlobalKey();
  double? _leadHeight;

  @override
  void initState() {
    super.initState();
    _scheduleHeightCheck();
  }

  void _scheduleHeightCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());
  }

  void _updateHeight() {
    if (!mounted) return;
    final renderBox = _leadKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.size.height != _leadHeight) {
      setState(() {
        _leadHeight = renderBox.size.height;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: widget.crossAxisAlignment,
      children: [
        Expanded(
          flex: widget.leadFlex,
          child: NotificationListener<SizeChangedLayoutNotification>(
            onNotification: (notification) {
              _scheduleHeightCheck();
              return true;
            },
            child: SizeChangedLayoutNotifier(
              child: Container(
                key: _leadKey,
                child: widget.leadChild,
              ),
            ),
          ),
        ),
        if (widget.gap > 0) SizedBox(width: widget.gap),
        Expanded(
          flex: widget.followingFlex,
          child: SizedBox(
            height: _leadHeight ?? 0, // Defaults to 0px for 16ms during the very first frame
            child: widget.followingChild,
          ),
        ),
      ],
    );
  }
}
