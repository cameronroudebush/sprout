import 'package:material_ui/material_ui.dart';

enum BuiltWithAiTooltipDirection { above, right }

/// Indicates content built with AI and exposes the model on hover.
class BuiltWithAiIndicator extends StatelessWidget {
  final String? model;
  final Color? color;
  final double size;
  final BuiltWithAiTooltipDirection tooltipDirection;

  const BuiltWithAiIndicator({
    super.key,
    this.model,
    this.color,
    this.size = 24,
    this.tooltipDirection = BuiltWithAiTooltipDirection.above,
  });

  Offset _positionTooltipToRight(TooltipPositionContext position) {
    final maxX = (position.overlaySize.width - position.tooltipSize.width)
        .clamp(0.0, double.infinity);
    final maxY = (position.overlaySize.height - position.tooltipSize.height)
        .clamp(0.0, double.infinity);
    final x = (position.target.dx + position.targetSize.width / 2 + 8)
        .clamp(0.0, maxX)
        .toDouble();
    final y = (position.target.dy - position.tooltipSize.height / 2)
        .clamp(0.0, maxY)
        .toDouble();

    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final value = model?.trim();
    final message = value == null || value.isEmpty
        ? 'Built with AI'
        : 'Built with AI\nModel: $value';

    return Tooltip(
      message: message,
      preferBelow: false,
      textAlign: TextAlign.center,
      positionDelegate: tooltipDirection == BuiltWithAiTooltipDirection.right
          ? _positionTooltipToRight
          : null,
      child: Icon(Icons.auto_awesome, color: color, size: size),
    );
  }
}
