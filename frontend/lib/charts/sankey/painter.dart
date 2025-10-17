import 'dart:ui' as ui;

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
  final String Function(double val)? formatter;

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
    String tooltipTitle = '';
    String tooltipValue = '';

    if (hoveredNode != null) {
      final value = data.nodeValues[hoveredNode!] ?? 0.0;
      tooltipTitle = hoveredNode!;
      tooltipValue = formatter != null ? formatter!(value) : value.toStringAsFixed(0);
    } else if (hoveredLink != null) {
      final link = hoveredLink!;
      // For this example, we'll use a placeholder date, but you might pass this in.
      tooltipTitle = '${link.source} to ${link.target}';
      tooltipValue = formatter != null ? formatter!(link.value) : '\$${link.value.toStringAsFixed(2)}';
    }

    if (tooltipTitle.isEmpty && tooltipValue.isEmpty) return;

    // Define Padding and Spacing
    const double horizontalPadding = 12.0;
    const double verticalPadding = 4.0;
    const double spacing = 4.0;

    // Title Painter (e.g., "Income")
    final titlePainter = TextPainter(
      text: TextSpan(
        text: tooltipTitle,
        style: const TextStyle(color: _tooltipTitleColor, fontSize: 14),
      ),
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: size.width);

    // Value Painter (e.g., "$46,122.44")
    final valuePainter = TextPainter(
      text: TextSpan(
        text: tooltipValue,
        style: const TextStyle(color: _tooltipValueColor, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: size.width);

    // --- Calculate Tooltip Dimensions ---
    final double contentWidth = titlePainter.width > valuePainter.width ? titlePainter.width : valuePainter.width;
    final double tooltipWidth = contentWidth + horizontalPadding * 2;
    final double tooltipHeight = titlePainter.height + valuePainter.height + spacing + verticalPadding * 2;
    final tooltipSize = Size(tooltipWidth, tooltipHeight);

    // --- Adjust Position to Keep Tooltip on Screen ---
    double dx = hoverPosition!.dx + 15;
    double dy = hoverPosition!.dy + 15;

    if (dx + tooltipSize.width > size.width) {
      dx = hoverPosition!.dx - tooltipSize.width - 15;
    }
    if (dy + tooltipSize.height > size.height) {
      dy = hoverPosition!.dy - tooltipSize.height - 15;
    }

    // --- Draw the Tooltip Background ---
    final rect = Rect.fromLTWH(dx, dy, tooltipSize.width, tooltipSize.height);
    final paint = Paint()..color = _tooltipBackgroundColor;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), paint);

    // --- Paint the Centered Text ---
    // Center the title horizontally
    final titleDx = rect.left + (tooltipWidth - titlePainter.width) / 2;
    titlePainter.paint(canvas, Offset(titleDx, rect.top + verticalPadding));

    // Center the value horizontally, positioned below the title
    final valueDx = rect.left + (tooltipWidth - valuePainter.width) / 2;
    final valueDy = rect.top + verticalPadding + titlePainter.height + spacing;
    valuePainter.paint(canvas, Offset(valueDx, valueDy));
  }

  @override
  bool shouldRepaint(covariant SankeyPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.hoveredNode != hoveredNode ||
        oldDelegate.hoveredLink != hoveredLink ||
        oldDelegate.hoverPosition != hoverPosition;
  }
}
