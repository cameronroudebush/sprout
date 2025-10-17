import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:sprout/charts/sankey/models/link.dart';
import 'package:sprout/charts/sankey/models/painter.dart';

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

  Color _getColorForNode(SankeyPainterData data, String nodeName) {
    const defaultColor = Colors.grey;
    final colorString = data.sankeyData.colors[nodeName];
    if (colorString == null) return defaultColor;
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return defaultColor;
    }
  }

  void _paintLabel(Canvas canvas, String name, Rect rect, {Color textColor = Colors.black87}) {
    double totalValue = data.nodeValues[name] ?? 0.0;
    String displayVal;
    if (formatter != null) {
      displayVal = formatter!(totalValue);
    } else {
      displayVal = totalValue.toStringAsFixed(0);
    }

    final textSpan = TextSpan(
      text: '$name\n$displayVal',
      style: TextStyle(
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            blurRadius: 1,
            color: textColor == Colors.white ? Colors.black.withValues(alpha: 0.5) : Colors.transparent,
          ),
        ],
      ),
    );
    final textPainter = TextPainter(text: textSpan, textAlign: TextAlign.center, textDirection: ui.TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: rect.width);

    // The check for height is removed, as the node is now guaranteed to be tall enough.
    final offset = Offset(rect.center.dx - textPainter.width / 2, rect.center.dy - textPainter.height / 2);
    textPainter.paint(canvas, offset);
  }

  void _paintTooltip(Canvas canvas, Size size) {
    String tooltipText = '';
    if (hoveredNode != null) {
      final value = data.nodeValues[hoveredNode!] ?? 0.0;
      tooltipText = '$hoveredNode: \$${value.toStringAsFixed(0)}';
    } else if (hoveredLink != null) {
      final link = hoveredLink!;
      final valueStr = formatter != null ? formatter!(link.value) : '\$${link.value.toStringAsFixed(0)}';
      tooltipText = '${link.source} → ${link.target}: $valueStr';
      if (link.description != null && link.description!.isNotEmpty) {
        tooltipText += '\n${link.description}';
      }
    }
    if (tooltipText.isEmpty) return;

    final textSpan = TextSpan(
      text: tooltipText,
      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
    );
    final textPainter = TextPainter(text: textSpan, textAlign: TextAlign.left, textDirection: ui.TextDirection.ltr)
      ..layout();

    final tooltipSize = Size(textPainter.width + 16, textPainter.height + 10);
    double dx = hoverPosition!.dx + 15;
    double dy = hoverPosition!.dy + 15;

    if (dx + tooltipSize.width > size.width) {
      dx = hoverPosition!.dx - tooltipSize.width - 15;
    }
    if (dy + tooltipSize.height > size.height) {
      dy = hoverPosition!.dy - tooltipSize.height - 15;
    }

    final rect = Rect.fromLTWH(dx, dy, tooltipSize.width, tooltipSize.height);
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.75);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), paint);

    textPainter.paint(canvas, Offset(rect.left + 8, rect.top + 5));
  }

  @override
  bool shouldRepaint(covariant SankeyPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.hoveredNode != hoveredNode ||
        oldDelegate.hoveredLink != hoveredLink ||
        oldDelegate.hoverPosition != hoverPosition;
  }
}
