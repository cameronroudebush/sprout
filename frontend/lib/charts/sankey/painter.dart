import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sprout/charts/sankey/models/link.dart';
import 'package:sprout/charts/sankey/models/painter.dart';

const Color _tooltipBackgroundColor = Color(0xFF4A5568); // Dark slate gray
const Color _tooltipTitleColor = Color(0xFFE2E8F0); // Light gray for title/date
const Color _tooltipValueColor = Color(0xFF68D391); // Vibrant green for value
const Color _defaultNodeColor = Color(0xFF38A169); // Main green for nodes/links
const Color _labelTextColor = Colors.black;

/// The sankey painter is used to render the actual sankey diagram with pre-computed data using the [CustomPainter]
class SankeyPainter extends CustomPainter {
  final SankeyPainterData data;
  final String? hoveredNode;
  final SankeyLink? hoveredLink;
  final Offset? hoverPosition;

  /// A formatter that allows us to customize how the value is displayed
  final String Function(num val)? formatter;

  SankeyPainter({required this.data, this.hoveredNode, this.hoveredLink, this.hoverPosition, this.formatter});

  @override
  void paint(Canvas canvas, Size size) {
    final linkPaint = Paint()..style = PaintingStyle.fill;
    final nodePaint = Paint()..style = PaintingStyle.fill;
    bool isAnythingHovered = hoveredNode != null || hoveredLink != null;

    for (var link in data.links) {
      if (data.linkPaths[link] == null) continue;
      bool isHighlighted = hoveredNode == link.source || hoveredNode == link.target || hoveredLink == link;
      final color = _getColorForNode(data, link.source);
      linkPaint.color = isAnythingHovered
          ? (isHighlighted ? color.withValues(alpha: 0.7) : color.withValues(alpha: 0.1))
          : color.withValues(alpha: 0.4);
      canvas.drawPath(data.linkPaths[link]!, linkPaint);
    }

    data.nodeRects.forEach((name, rect) {
      bool isHighlighted = hoveredNode == name || hoveredLink?.source == name || hoveredLink?.target == name;
      final color = _getColorForNode(data, name);

      nodePaint.color = isAnythingHovered ? (isHighlighted ? color : color.withValues(alpha: 0.3)) : color;
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), nodePaint);
    });

    data.nodeRects.forEach((name, rect) {
      // Don't draw label if node is too small
      if (rect.height < 30) {
        return;
      }
      _paintLabel(canvas, name, rect);
    });

    if (hoverPosition != null) {
      _paintTooltip(canvas, size);
    }
  }

  /// Retrieves the color for a given node, defaulting to the new theme color.
  Color _getColorForNode(SankeyPainterData data, String nodeName) {
    const defaultColor = _defaultNodeColor;
    final colorString = data.sankeyData.colors[nodeName];
    if (colorString == null) return defaultColor;
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return defaultColor;
    }
  }

  /// Paints the text label inside a node.
  void _paintLabel(Canvas canvas, String name, Rect rect, {Color textColor = _labelTextColor}) {
    double totalValue = data.nodeValues[name] ?? 0.0;
    String displayVal;
    if (formatter != null) {
      displayVal = formatter!(totalValue);
    } else {
      displayVal = totalValue.toStringAsFixed(0);
    }

    final textSpan = TextSpan(
      text: '$name\n$displayVal',
      style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
    );
    final textPainter = TextPainter(text: textSpan, textAlign: TextAlign.center, textDirection: ui.TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: rect.width);

    final offset = Offset(rect.center.dx - textPainter.width / 2, rect.center.dy - textPainter.height / 2);
    textPainter.paint(canvas, offset);
  }

  /// Paints a styled tooltip that matches the provided image.
  void _paintTooltip(Canvas canvas, Size size) {
    if (hoverPosition == null) return;

    String title = '';
    String value = '';
    String? description;

    if (hoveredNode != null) {
      final val = data.nodeValues[hoveredNode!] ?? 0.0;
      title = hoveredNode!;
      value = formatter != null ? formatter!(val) : val.toStringAsFixed(0);
      description = data.links.firstWhereOrNull((e) => e.source == hoveredNode || e.target == hoveredNode)?.description;
    } else if (hoveredLink != null) {
      final link = hoveredLink!;
      title = '${link.source} to ${link.target}';
      value = formatter != null ? formatter!(link.value) : '\$${link.value.toStringAsFixed(2)}';
      description = link.description;
    }

    if (title.isEmpty && value.isEmpty) return;

    const double hPadding = 12.0;
    const double vPadding = 4.0;
    const double spacing = 4.0;

    // Define styles here to keep code clean
    const titleStyle = TextStyle(color: _tooltipTitleColor, fontSize: 14);
    const valueStyle = TextStyle(color: _tooltipValueColor, fontSize: 14, fontWeight: FontWeight.bold);
    const descStyle = TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic);

    TextPainter createPainter(String text, TextStyle style) {
      return TextPainter(
        text: TextSpan(text: text, style: style),
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr,
      )..layout(minWidth: 0, maxWidth: size.width);
    }

    // Build the list of active painters dynamically
    final painters = [
      createPainter(title, titleStyle),
      createPainter(value, valueStyle),
      if (description != null && description.isNotEmpty) createPainter(description, descStyle),
    ];

    // Calculate Dimensions using the List
    double maxContentWidth = 0;
    double totalContentHeight = 0;

    for (var p in painters) {
      if (p.width > maxContentWidth) maxContentWidth = p.width;
      totalContentHeight += p.height;
    }

    // Add spacing only between items (count - 1)
    final totalSpacing = (painters.length - 1) * spacing;
    final tooltipWidth = maxContentWidth + (hPadding * 2);
    final tooltipHeight = totalContentHeight + totalSpacing + (vPadding * 2);

    // Adjust Position (Boundary Checks)
    double dx = hoverPosition!.dx + 15;
    double dy = hoverPosition!.dy + 15;

    if (dx + tooltipWidth > size.width) dx = hoverPosition!.dx - tooltipWidth - 15;
    if (dy + tooltipHeight > size.height) dy = hoverPosition!.dy - tooltipHeight - 15;

    // Draw Background
    final rect = Rect.fromLTWH(dx, dy, tooltipWidth, tooltipHeight);
    final bgPaint = Paint()..color = _tooltipBackgroundColor;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), bgPaint);

    // Paint Text Stack
    double currentDy = rect.top + vPadding;

    for (var p in painters) {
      // Center horizontally
      final pDx = rect.left + (tooltipWidth - p.width) / 2;
      p.paint(canvas, Offset(pDx, currentDy));

      // Move cursor down for next item
      currentDy += p.height + spacing;
    }
  }

  @override
  bool shouldRepaint(covariant SankeyPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.hoveredNode != hoveredNode ||
        oldDelegate.hoveredLink != hoveredLink ||
        oldDelegate.hoverPosition != hoverPosition;
  }
}
