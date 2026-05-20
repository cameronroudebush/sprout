import 'dart:math';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';

/// A private class to cache heavy mathematical layout computations.
class _SankeyLayoutData {
  final Map<String, Rect> nodeRects;
  final Map<SankeyLink, Path> linkPaths;
  final Map<String, double> nodeValues;

  _SankeyLayoutData({
    required this.nodeRects,
    required this.linkPaths,
    required this.nodeValues,
  });
}

/// A mobile-friendly, highly performant Sankey chart.
class SproutSankeyChart extends StatefulWidget {
  final SankeyData data;
  final String Function(num val)? formatter;
  final void Function(String node, double value)? onNodeTap;
  final void Function(SankeyLink link)? onLinkTap;

  /// Minimum width before the chart becomes horizontally scrollable on mobile.
  final double minWidth;

  const SproutSankeyChart({
    super.key,
    required this.data,
    this.formatter,
    this.onNodeTap,
    this.onLinkTap,
    this.minWidth = 600.0,
  });

  @override
  State<SproutSankeyChart> createState() => _SproutSankeyChartState();
}

class _SproutSankeyChartState extends State<SproutSankeyChart> {
  _SankeyLayoutData? _layoutData;
  Size? _lastComputedSize;

  Offset? _hoverPosition;
  String? _hoveredNode;
  SankeyLink? _hoveredLink;

  void _handleInteraction(Offset position) {
    if (_layoutData == null) return;

    String? newNode;
    SankeyLink? newLink;

    for (var entry in _layoutData!.nodeRects.entries) {
      if (entry.value.contains(position)) {
        newNode = entry.key;
        break;
      }
    }

    if (newNode == null) {
      for (var entry in _layoutData!.linkPaths.entries) {
        if (entry.value.contains(position)) {
          newLink = entry.key;
          break;
        }
      }
    }

    if (newNode != _hoveredNode || newLink != _hoveredLink || _hoverPosition != position) {
      setState(() {
        _hoverPosition = position;
        _hoveredNode = newNode;
        _hoveredLink = newLink;
      });
    }
  }

  void _handleTap() {
    if (_hoveredNode != null && widget.onNodeTap != null) {
      widget.onNodeTap!(_hoveredNode!, _layoutData!.nodeValues[_hoveredNode!] ?? 0);
    } else if (_hoveredLink != null && widget.onLinkTap != null) {
      widget.onLinkTap!(_hoveredLink!);
    }
  }

  void _clearInteraction() {
    if (_hoverPosition != null) {
      setState(() {
        _hoverPosition = null;
        _hoveredNode = null;
        _hoveredLink = null;
      });
    }
  }

  @override
  void didUpdateWidget(covariant SproutSankeyChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _layoutData = null; // Force layout recalculation if data changes
    }
  }

  /// Calculates the required height based on the total number of nodes
  double _calculateRequiredHeight(SankeyData data) {
    final Set<String> nodeNames = {};
    final Map<String, List<String>> nodeParents = {};
    final Map<String, List<String>> nodeChildren = {};
    for (var link in data.links) {
      nodeNames.add(link.source_);
      nodeNames.add(link.target);
      nodeChildren.putIfAbsent(link.source_, () => []).add(link.target);
      nodeParents.putIfAbsent(link.target, () => []).add(link.source_);
    }
    final Map<String, int> nodeColumns = {};
    List<String> currentColumnNodes =
        nodeNames.where((n) => nodeParents[n] == null || nodeParents[n]!.isEmpty).toList();
    int column = 0;
    while (currentColumnNodes.isNotEmpty) {
      for (var node in currentColumnNodes) {
        nodeColumns[node] = column;
      }
      final nextColumnNodes = <String>{};
      for (var node in currentColumnNodes) {
        if (nodeChildren[node] != null) nextColumnNodes.addAll(nodeChildren[node]!);
      }
      currentColumnNodes = nextColumnNodes.where((n) {
        if (nodeColumns.containsKey(n)) return false;
        final parents = nodeParents[n];
        return parents == null || parents.isEmpty || parents.every((p) => nodeColumns.containsKey(p));
      }).toList();
      column++;
    }
    for (var node in nodeNames.where((n) => !nodeColumns.containsKey(n))) {
      nodeColumns[node] = column > 0 ? column - 1 : 0;
    }
    final int numColumns = nodeColumns.isEmpty ? 0 : nodeColumns.values.reduce(max) + 1;
    final List<int> columnCounts = List.generate(numColumns, (_) => 0);
    nodeColumns.forEach((node, col) => columnCounts[col]++);
    final int maxNodesInAnyColumn = columnCounts.isEmpty ? 0 : columnCounts.reduce(max);
    const double minNodeHeight = 40.0;
    const double nodePadding = 16.0;
    return (maxNodesInAnyColumn * minNodeHeight) + ((maxNodesInAnyColumn - 1) * nodePadding);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final double dynamicHeight = _calculateRequiredHeight(widget.data);

    Widget chartContent = SizedBox(
      height: dynamicHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Enforce a minimum width to prevent unreadable squishing on mobile
          final isScrollableX = constraints.maxWidth < widget.minWidth;
          final chartWidth = isScrollableX ? widget.minWidth : constraints.maxWidth;
          final chartSize = Size(chartWidth, dynamicHeight);

          // Memoize the heavy layout computation
          if (_layoutData == null || _lastComputedSize != chartSize) {
            _layoutData = _computeLayout(chartSize);
            _lastComputedSize = chartSize;
          }

          Widget chartArea = MouseRegion(
            onHover: (e) => _handleInteraction(e.localPosition),
            onExit: (_) => _clearInteraction(),
            child: GestureDetector(
              onTapDown: (details) => _handleInteraction(details.localPosition),
              onTapUp: (_) => _handleTap(),
              onTapCancel: _clearInteraction,
              onLongPressStart: (details) => _handleInteraction(details.localPosition),
              onLongPressMoveUpdate: (details) => _handleInteraction(details.localPosition),
              onLongPressEnd: (_) => _clearInteraction(),
              child: CustomPaint(
                size: chartSize,
                painter: _SankeyPainter(
                  layoutData: _layoutData!,
                  sankeyData: widget.data,
                  theme: theme,
                  hoveredNode: _hoveredNode,
                  hoveredLink: _hoveredLink,
                  hoverPosition: _hoverPosition,
                  formatter: widget.formatter,
                ),
              ),
            ),
          );

          if (isScrollableX) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: chartArea,
            );
          }

          return chartArea;
        },
      ),
    );

    return chartContent;
  }

  /// The heavy math engine. Extracted here so it only runs when size or data changes.
  _SankeyLayoutData _computeLayout(Size size) {
    final Set<String> nodeNames = {};
    final Map<String, double> nodeIncoming = {};
    final Map<String, double> nodeOutgoing = {};
    final Map<String, List<String>> nodeChildren = {};
    final Map<String, List<String>> nodeParents = {};

    for (var link in widget.data.links) {
      nodeNames.add(link.source_);
      nodeNames.add(link.target);
      nodeOutgoing[link.source_] = (nodeOutgoing[link.source_] ?? 0) + link.value;
      nodeIncoming[link.target] = (nodeIncoming[link.target] ?? 0) + link.value;
      nodeChildren.putIfAbsent(link.source_, () => []).add(link.target);
      nodeParents.putIfAbsent(link.target, () => []).add(link.source_);
    }

    final Map<String, double> nodeValues = {};
    for (var name in nodeNames) {
      nodeValues[name] = max(nodeIncoming[name] ?? 0.0, nodeOutgoing[name] ?? 0.0);
    }

    // Layering Algorithm
    final Map<String, int> nodeColumns = {};
    List<String> currentColumnNodes =
        nodeNames.where((n) => nodeParents[n] == null || nodeParents[n]!.isEmpty).toList();
    int column = 0;

    while (currentColumnNodes.isNotEmpty) {
      for (var node in currentColumnNodes) {
        nodeColumns[node] = column;
      }
      final nextColumnNodes = <String>{};
      for (var node in currentColumnNodes) {
        if (nodeChildren[node] != null) nextColumnNodes.addAll(nodeChildren[node]!);
      }
      currentColumnNodes = nextColumnNodes.where((n) {
        if (nodeColumns.containsKey(n)) return false;
        final parents = nodeParents[n];
        return parents == null || parents.isEmpty || parents.every((p) => nodeColumns.containsKey(p));
      }).toList();
      column++;
    }

    // Assign stragglers
    for (var node in nodeNames.where((n) => !nodeColumns.containsKey(n))) {
      nodeColumns[node] = column > 0 ? column - 1 : 0;
    }

    final int numColumns = nodeColumns.isEmpty ? 0 : nodeColumns.values.reduce(max) + 1;
    final List<List<String>> columns = List.generate(numColumns, (_) => []);
    nodeColumns.forEach((node, col) => columns[col].add(node));

    // Layout Nodes
    final Map<String, Rect> nodeRects = {};
    const double nodeThickness = 80.0;
    const double nodePadding = 16.0;
    final double gap = (numColumns > 1) ? (size.width - (numColumns * nodeThickness)) / (numColumns - 1) : 0;
    const double minNodeHeight = 40.0;

    for (int i = 0; i < columns.length; i++) {
      final List<String> nodesInColumn = columns[i];
      if (nodesInColumn.isEmpty) continue;

      double totalColumnValue = nodesInColumn.fold(0.0, (sum, node) => sum + (nodeValues[node] ?? 0.0));
      if (totalColumnValue == 0) totalColumnValue = 1.0;

      final double availableSpace = size.height - (nodePadding * (nodesInColumn.length - 1));
      final double totalMinHeight = minNodeHeight * nodesInColumn.length;
      final double effectiveHeight = max(availableSpace, totalMinHeight);
      final double distributableSpace = effectiveHeight - totalMinHeight;

      double currentPos = 0;
      final double fixedPos = i * (nodeThickness + gap);

      for (String nodeName in nodesInColumn) {
        final double nodeFlowValue = nodeValues[nodeName] ?? 0.0;
        final double proportionalShare = (nodeFlowValue / totalColumnValue) * distributableSpace;
        final double nodeSize = minNodeHeight + proportionalShare;

        nodeRects[nodeName] = Rect.fromLTWH(fixedPos, currentPos, nodeThickness, nodeSize);
        currentPos += nodeSize + nodePadding;
      }
    }

    // Layout Links
    final Map<SankeyLink, Path> linkPaths = {};
    final Map<String, double> currentOutgoingOffset = {};
    final Map<String, double> currentIncomingOffset = {};

    final sortedLinks = List<SankeyLink>.from(widget.data.links)
      ..sort((a, b) {
        final colA = nodeColumns[a.target] ?? 0;
        final colB = nodeColumns[b.target] ?? 0;
        if (colA != colB) return colA.compareTo(colB);
        final targetRectA = nodeRects[a.target];
        final targetRectB = nodeRects[b.target];
        if (targetRectA != null && targetRectB != null) return targetRectA.top.compareTo(targetRectB.top);
        return 0;
      });

    for (var link in sortedLinks) {
      final sourceRect = nodeRects[link.source_];
      final targetRect = nodeRects[link.target];
      if (sourceRect == null || targetRect == null) continue;

      final double sourceTotalFlow = nodeValues[link.source_] ?? 0.0;
      final double targetTotalFlow = nodeValues[link.target] ?? 0.0;

      final double sourceLinkRelativeSize =
          (sourceTotalFlow > 0) ? (link.value / sourceTotalFlow) * sourceRect.height : 0;
      final double targetLinkRelativeSize =
          (targetTotalFlow > 0) ? (link.value / targetTotalFlow) * targetRect.height : 0;

      final double currentSourceOffset = currentOutgoingOffset.putIfAbsent(link.source_, () => 0.0);
      final double currentTargetOffset = currentIncomingOffset.putIfAbsent(link.target, () => 0.0);

      currentOutgoingOffset[link.source_] = currentSourceOffset + sourceLinkRelativeSize;
      currentIncomingOffset[link.target] = currentTargetOffset + targetLinkRelativeSize;

      final Offset p1 = Offset(sourceRect.right, sourceRect.top + currentSourceOffset);
      final Offset p2 = Offset(sourceRect.right, sourceRect.top + currentSourceOffset + sourceLinkRelativeSize);
      final Offset p3 = Offset(targetRect.left, targetRect.top + currentTargetOffset + targetLinkRelativeSize);
      final Offset p4 = Offset(targetRect.left, targetRect.top + currentTargetOffset);

      final Offset controlPoint1 = Offset(p1.dx + (p4.dx - p1.dx) * 0.5, p1.dy);
      final Offset controlPoint2 = Offset(p4.dx - (p4.dx - p1.dx) * 0.5, p4.dy);

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p4.dx, p4.dy)
        ..lineTo(p3.dx, p3.dy)
        ..cubicTo(controlPoint2.dx, p3.dy, controlPoint1.dx, p2.dy, p2.dx, p2.dy)
        ..close();

      linkPaths[link] = path;
    }

    return _SankeyLayoutData(nodeRects: nodeRects, linkPaths: linkPaths, nodeValues: nodeValues);
  }
}

/// The visual rendering engine. Keeps frame rates high by only doing paint operations.
class _SankeyPainter extends CustomPainter {
  final _SankeyLayoutData layoutData;
  final SankeyData sankeyData;
  final ThemeData theme;
  final String? hoveredNode;
  final SankeyLink? hoveredLink;
  final Offset? hoverPosition;
  final String Function(num val)? formatter;

  final Color _tooltipBgColor = const Color(0xFF4A5568);
  final Color _defaultNodeColor = const Color(0xFF38A169);

  _SankeyPainter({
    required this.layoutData,
    required this.sankeyData,
    required this.theme,
    this.hoveredNode,
    this.hoveredLink,
    this.hoverPosition,
    this.formatter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linkPaint = Paint()..style = PaintingStyle.fill;
    final nodePaint = Paint()..style = PaintingStyle.fill;
    bool isAnythingHovered = hoveredNode != null || hoveredLink != null;

    for (var link in sankeyData.links) {
      if (layoutData.linkPaths[link] == null) continue;
      bool isHighlighted = hoveredNode == link.source_ || hoveredNode == link.target || hoveredLink == link;
      final color = _getColorForNode(link.source_);

      linkPaint.color = isAnythingHovered
          ? (isHighlighted ? color.withOpacity(0.7) : color.withOpacity(0.1))
          : color.withOpacity(0.4);
      canvas.drawPath(layoutData.linkPaths[link]!, linkPaint);
    }

    layoutData.nodeRects.forEach((name, rect) {
      bool isHighlighted = hoveredNode == name || hoveredLink?.source_ == name || hoveredLink?.target == name;
      final color = _getColorForNode(name);

      nodePaint.color = isAnythingHovered ? (isHighlighted ? color : color.withOpacity(0.3)) : color;
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), nodePaint);

      if (rect.height >= 30) {
        _paintLabel(canvas, name, rect);
      }
    });

    if (hoverPosition != null) {
      _paintTooltip(canvas, size);
    }
  }

  Color _getColorForNode(String nodeName) {
    final colorString = sankeyData.colors[nodeName];
    if (colorString == null) return _defaultNodeColor;
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (_) {
      return _defaultNodeColor;
    }
  }

  void _paintLabel(Canvas canvas, String name, Rect rect) {
    double totalValue = layoutData.nodeValues[name] ?? 0.0;
    String displayVal = formatter != null ? formatter!(totalValue) : totalValue.toStringAsFixed(0);

    final textSpan = TextSpan(
      text: '$name\n$displayVal',
      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
    );
    final textPainter = TextPainter(text: textSpan, textAlign: TextAlign.center, textDirection: ui.TextDirection.ltr)
      ..layout(maxWidth: rect.width);

    final offset = Offset(rect.center.dx - textPainter.width / 2, rect.center.dy - textPainter.height / 2);
    textPainter.paint(canvas, offset);
  }

  void _paintTooltip(Canvas canvas, Size size) {
    if (hoverPosition == null) return;

    String title = '';
    String value = '';
    String? description;

    if (hoveredNode != null) {
      final val = layoutData.nodeValues[hoveredNode!] ?? 0.0;
      title = hoveredNode!;
      value = formatter != null ? formatter!(val) : val.toStringAsFixed(0);

      // Attempt to find a description from connected links
      try {
        description =
            sankeyData.links.firstWhereOrNull((e) => e.source_ == hoveredNode || e.target == hoveredNode)?.description;
      } catch (_) {}
    } else if (hoveredLink != null) {
      title = '${hoveredLink!.source_} → ${hoveredLink!.target}';
      value = formatter != null ? formatter!(hoveredLink!.value) : '\$${hoveredLink!.value.toStringAsFixed(2)}';

      // Fallback to dynamic if your generated SankeyLink model doesn't officially expose description yet
      try {
        description = (hoveredLink as dynamic).description;
      } catch (_) {}
    }

    if (title.isEmpty && value.isEmpty) return;

    final titleSpan =
        TextSpan(text: title, style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 14, height: 1.1));
    final valueSpan = TextSpan(
        text: value,
        style: const TextStyle(color: Color(0xFF68D391), fontSize: 14, fontWeight: FontWeight.bold, height: 1.1));

    final painters = [
      TextPainter(text: titleSpan, textDirection: ui.TextDirection.ltr)..layout(),
      TextPainter(text: valueSpan, textDirection: ui.TextDirection.ltr)..layout(),
    ];

    if (description != null && description.isNotEmpty) {
      final descSpan = TextSpan(
          text: description, style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic));
      painters.add(TextPainter(text: descSpan, textDirection: ui.TextDirection.ltr)..layout());
    }

    double maxContentWidth = 0;
    double totalContentHeight = 0;
    const double spacing = 2.0;

    for (var p in painters) {
      if (p.width > maxContentWidth) maxContentWidth = p.width;
      totalContentHeight += p.height;
    }

    final totalSpacing = (painters.length - 1) * spacing;
    final tooltipWidth = maxContentWidth + 24.0;
    final tooltipHeight = totalContentHeight + totalSpacing + 16.0;

    double dx = hoverPosition!.dx + 15;
    double dy = hoverPosition!.dy + 15;
    if (dx + tooltipWidth > size.width) dx = hoverPosition!.dx - tooltipWidth - 15;
    if (dy + tooltipHeight > size.height) dy = hoverPosition!.dy - tooltipHeight - 15;

    // Draw Background
    final rect = Rect.fromLTWH(dx, dy, tooltipWidth, tooltipHeight);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), Paint()..color = _tooltipBgColor);

    // Paint Text Stack Centered
    double currentDy = dy + 8.0;
    for (var p in painters) {
      final pDx = dx + 12.0 + ((maxContentWidth - p.width) / 2);
      p.paint(canvas, Offset(pDx, currentDy));
      currentDy += p.height + spacing;
    }
  }

  @override
  bool shouldRepaint(covariant _SankeyPainter oldDelegate) {
    return oldDelegate.layoutData != layoutData ||
        oldDelegate.hoveredNode != hoveredNode ||
        oldDelegate.hoveredLink != hoveredLink ||
        oldDelegate.hoverPosition != hoverPosition;
  }
}
