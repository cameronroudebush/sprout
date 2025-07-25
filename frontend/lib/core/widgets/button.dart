import 'package:flutter/material.dart';

/// A reusable button that helps with default sizing for mobile
class ButtonWidget extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double fontSize;
  final double minSize;
  final Color? color;

  const ButtonWidget({
    super.key,
    this.text,
    this.icon,
    this.onPressed,
    this.fontSize = 16,
    this.minSize = double.infinity,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      minimumSize: Size(minSize, 40),
      elevation: 5,
      backgroundColor: color ?? Theme.of(context).buttonTheme.colorScheme!.onPrimary,
    );

    if (icon != null && text != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text!, style: TextStyle(fontSize: fontSize)),
        style: buttonStyle,
      );
    } else if (icon != null && text == null) {
      return ElevatedButton(onPressed: onPressed, style: buttonStyle, child: Icon(icon));
    } else if (icon == null && text != null) {
      return ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: Text(text!, style: TextStyle(fontSize: fontSize)),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
