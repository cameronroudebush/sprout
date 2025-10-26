import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:sprout/charts/sankey/models/data.dart';
import 'package:sprout/charts/sankey/models/link.dart';
import 'package:sprout/charts/sankey/models/painter.dart';
import 'package:sprout/charts/sankey/painter.dart';

/// Generate a sankey chart given the links: https://en.wikipedia.org/wiki/Sankey_diagram
class SankeyChart extends StatefulWidget {
  final SankeyData sankeyData;

  /// The direction to render the chart
  final Axis direction;

  /// A formatter that allows us to customize how the value is displayed
  final String Function(num val)? formatter;

  const SankeyChart({super.key, required this.sankeyData, this.formatter, this.direction = Axis.horizontal});

  @override
  State<SankeyChart> createState() => _SankeyChartState();
}

class _SankeyChartState extends State<SankeyChart> {
  Offset? _hoverPosition;
  String? _hoveredNode;
  SankeyLink? _hoveredLink;
  SankeyPainterData? _painterData;

  /// Tracks which node is hovered so we can display the proper tooltip data
  void _updateHover(Offset position, Size size) {
    _painterData ??= _prepareData(size);
    final data = _painterData!;

    String? newHoveredNode;
    SankeyLink? newHoveredLink;

    for (var entry in data.nodeRects.entries) {
      if (entry.value.contains(position)) {
        newHoveredNode = entry.key;
        break;
      }
    }

    if (newHoveredNode == null) {
      for (var entry in data.linkPaths.entries) {
        if (entry.value.contains(position)) {
          newHoveredLink = entry.key;
          break;
        }
      }
    }

    if (newHoveredNode != _hoveredNode || newHoveredLink != _hoveredLink) {
      setState(() {
        _hoverPosition = position;
        _hoveredNode = newHoveredNode;
        _hoveredLink = newHoveredLink;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _painterData = _prepareData(constraints.biggest);

        return MouseRegion(
          onHover: (event) => _updateHover(event.localPosition, constraints.biggest),
          onExit: (_) => setState(() {
            _hoverPosition = null;
            _hoveredNode = null;
            _hoveredLink = null;
          }),
          child: CustomPaint(
            size: constraints.biggest,
            painter: SankeyPainter(
              data: _painterData!,
              hoveredNode: _hoveredNode,
              hoveredLink: _hoveredLink,
              hoverPosition: _hoverPosition,
              formatter: widget.formatter,
            ),
          ),
        );
      },
    );
  }

  /// Prepares the data to compute how to display our sankey chart
  SankeyPainterData _prepareData(Size size) {
    final Set<String> nodeNames = {};
    final Map<String, double> nodeValues = {};
    final Map<String, List<String>> nodeChildren = {};
    final Map<String, List<String>> nodeParents = {};

    final Map<String, double> nodeIncoming = {};
    final Map<String, double> nodeOutgoing = {};

    for (var link in widget.sankeyData.links) {
      nodeNames.add(link.source);
      nodeNames.add(link.target);

      // Track outgoing and incoming flows separately
      nodeOutgoing[link.source] = (nodeOutgoing[link.source] ?? 0) + link.value;
      nodeIncoming[link.target] = (nodeIncoming[link.target] ?? 0) + link.value;

      nodeChildren.putIfAbsent(link.source, () => []).add(link.target);
      nodeParents.putIfAbsent(link.target, () => []).add(link.source);
    }

    // =================================================================
    // START: Corrected Node Value Calculation
    // =================================================================
    // The value of a node is the maximum of its total inflows or outflows.
    // This ensures the node is large enough for all links and correctly represents
    // the total flow passing through it.
    for (var name in nodeNames) {
      final inflow = nodeIncoming[name] ?? 0.0;
      final outflow = nodeOutgoing[name] ?? 0.0;
      nodeValues[name] = max(inflow, outflow);
    }
    // =================================================================
    // END: Corrected Node Value Calculation
    // =================================================================

    // Layering Algorithm
    final Map<String, int> nodeColumns = {};
    List<String> currentColumnNodes = nodeNames
        .where((n) => nodeParents[n] == null || nodeParents[n]!.isEmpty)
        .toList();
    int column = 0;

    while (currentColumnNodes.isNotEmpty) {
      for (var node in currentColumnNodes) {
        nodeColumns[node] = column;
      }
      final nextColumnNodes = <String>{};
      for (var node in currentColumnNodes) {
        if (nodeChildren[node] != null) {
          nextColumnNodes.addAll(nodeChildren[node]!);
        }
      }
      currentColumnNodes = nextColumnNodes.where((n) {
        if (nodeColumns.containsKey(n)) return false;
        final parents = nodeParents[n];
        if (parents == null || parents.isEmpty) return true;
        return parents.every((p) => nodeColumns.containsKey(p));
      }).toList();
      column++;
    }

    final remainingNodes = nodeNames.where((n) => !nodeColumns.containsKey(n));
    for (var node in remainingNodes) {
      nodeColumns[node] = column > 0 ? column - 1 : 0;
    }

    final int numColumns = nodeColumns.isEmpty ? 0 : nodeColumns.values.reduce(max) + 1;
    final List<List<String>> columns = List.generate(numColumns, (_) => []);
    nodeColumns.forEach((node, col) => columns[col].add(node));

    // Layout Nodes
    final Map<String, Rect> nodeRects = {};
    final isHorizontal = widget.direction == Axis.horizontal;
    const double nodeThickness = 100.0;
    const double nodePadding = 20.0;

    final double gap = (numColumns > 1) ? (size.width - (numColumns * nodeThickness)) / (numColumns - 1) : 0;
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Two\nLines',
        style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: nodeThickness);
    const double labelPadding = 8.0;
    final double minNodeHeight = textPainter.height + labelPadding;

    for (int i = 0; i < columns.length; i++) {
      final List<String> nodesInColumn = columns[i];
      if (nodesInColumn.isEmpty) continue;

      // =================================================================
      // START: Corrected Column Sizing Logic
      // =================================================================
      // Use the corrected `nodeValues` for all columns to ensure consistent sizing.
      double totalColumnValue = nodesInColumn.fold(0.0, (sum, node) => sum + (nodeValues[node] ?? 0.0));
      // =================================================================
      // END: Corrected Column Sizing Logic
      // =================================================================

      if (totalColumnValue == 0) totalColumnValue = 1.0;

      final double availableSpace =
          (isHorizontal ? size.height : size.width) - (nodePadding * (nodesInColumn.length - 1));
      double currentPos = 0;
      final double fixedPos = i * (nodeThickness + gap);
      final double totalMinHeight = minNodeHeight * nodesInColumn.length;
      final double distributableSpace = availableSpace - totalMinHeight;

      if (distributableSpace < 0) {
        final double equalSpace = availableSpace / nodesInColumn.length;
        for (String nodeName in nodesInColumn) {
          nodeRects[nodeName] = isHorizontal
              ? Rect.fromLTWH(fixedPos, currentPos, nodeThickness, max(0, equalSpace))
              : Rect.fromLTWH(currentPos, fixedPos, max(0, equalSpace), nodeThickness);
          currentPos += equalSpace + nodePadding;
        }
      } else {
        for (String nodeName in nodesInColumn) {
          // =================================================================
          // START: Corrected Node Sizing Logic
          // =================================================================
          // Use the corrected `nodeValues` for proportional sizing within the column.
          final double nodeFlowValue = nodeValues[nodeName] ?? 0.0;
          // =================================================================
          // END: Corrected Node Sizing Logic
          // =================================================================
          final double proportionalSpace = (nodeFlowValue / totalColumnValue) * distributableSpace;
          final double nodeSpace = minNodeHeight + proportionalSpace;
          nodeRects[nodeName] = isHorizontal
              ? Rect.fromLTWH(fixedPos, currentPos, nodeThickness, nodeSpace)
              : Rect.fromLTWH(currentPos, fixedPos, nodeSpace, nodeThickness);
          currentPos += nodeSpace + nodePadding;
        }
      }
    }

    // Layout the links
    final Map<SankeyLink, Path> linkPaths = {};
    final Map<String, double> currentOutgoingOffset = {};
    final Map<String, double> currentIncomingOffset = {};
    final sortedLinks = List<SankeyLink>.from(widget.sankeyData.links);
    sortedLinks.sort((a, b) {
      final colA = nodeColumns[a.target] ?? 0;
      final colB = nodeColumns[b.target] ?? 0;
      if (colA != colB) return colA.compareTo(colB);
      final targetRectA = nodeRects[a.target];
      final targetRectB = nodeRects[b.target];
      if (targetRectA != null && targetRectB != null) {
        return targetRectA.top.compareTo(targetRectB.top);
      }
      return 0;
    });

    for (var link in sortedLinks) {
      final sourceRect = nodeRects[link.source];
      final targetRect = nodeRects[link.target];
      if (sourceRect == null || targetRect == null) continue;

      final double sourceTotalFlow = nodeValues[link.source] ?? 0.0;
      final double targetTotalFlow = nodeValues[link.target] ?? 0.0;

      final double sourceNodeSize = isHorizontal ? sourceRect.height : sourceRect.width;
      final double targetNodeSize = isHorizontal ? targetRect.height : targetRect.width;

      final double sourceLinkRelativeSize = (sourceTotalFlow > 0) ? (link.value / sourceTotalFlow) * sourceNodeSize : 0;
      final double targetLinkRelativeSize = (targetTotalFlow > 0) ? (link.value / targetTotalFlow) * targetNodeSize : 0;

      final double currentSourceOffset = currentOutgoingOffset.putIfAbsent(link.source, () => 0.0);
      final double currentTargetOffset = currentIncomingOffset.putIfAbsent(link.target, () => 0.0);

      currentOutgoingOffset[link.source] = currentSourceOffset + sourceLinkRelativeSize;
      currentIncomingOffset[link.target] = currentTargetOffset + targetLinkRelativeSize;

      final Offset p1, p2, p3, p4;
      if (isHorizontal) {
        p1 = Offset(sourceRect.right, sourceRect.top + currentSourceOffset);
        p2 = Offset(sourceRect.right, sourceRect.top + currentSourceOffset + sourceLinkRelativeSize);
        p3 = Offset(targetRect.left, targetRect.top + currentTargetOffset + targetLinkRelativeSize);
        p4 = Offset(targetRect.left, targetRect.top + currentTargetOffset);
      } else {
        p1 = Offset(sourceRect.left + currentSourceOffset, sourceRect.bottom);
        p2 = Offset(sourceRect.left + currentSourceOffset + sourceLinkRelativeSize, sourceRect.bottom);
        p3 = Offset(targetRect.left + currentTargetOffset + targetLinkRelativeSize, targetRect.top);
        p4 = Offset(targetRect.left + currentTargetOffset, targetRect.top);
      }

      final Offset controlPoint1, controlPoint2;
      if (isHorizontal) {
        controlPoint1 = Offset(p1.dx + (p4.dx - p1.dx) * 0.5, p1.dy);
        controlPoint2 = Offset(p4.dx - (p4.dx - p1.dx) * 0.5, p4.dy);
      } else {
        controlPoint1 = Offset(p1.dx, p1.dy + (p4.dy - p1.dy) * 0.5);
        controlPoint2 = Offset(p4.dx, p4.dy - (p4.dy - p1.dy) * 0.5);
      }

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p4.dx, p4.dy)
        ..lineTo(p3.dx, p3.dy)
        ..cubicTo(
          isHorizontal ? controlPoint2.dx : p3.dx,
          isHorizontal ? p3.dy : controlPoint2.dy,
          isHorizontal ? controlPoint1.dx : p2.dx,
          isHorizontal ? p2.dy : controlPoint1.dy,
          p2.dx,
          p2.dy,
        )
        ..close();
      linkPaths[link] = path;
    }

    return SankeyPainterData(
      sankeyData: widget.sankeyData,
      nodeRects: nodeRects,
      linkPaths: linkPaths,
      nodeValues: nodeValues,
    );
  }
}
