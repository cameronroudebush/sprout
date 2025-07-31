import 'package:flutter/material.dart';

/// A reusable button that helps with default sizing for mobile
class ButtonWidget extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onPressed;

  /// Minimum width
  final double minSize;

  /// Height to set
  final double? height;
  final Color? color;

  const ButtonWidget({
    super.key,
    this.text,
    this.icon,
    this.onPressed,
    this.minSize = double.infinity,
    this.color,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      minimumSize: Size(minSize, height ?? mediaQuery.size.height * .03),
      elevation: 5,
      backgroundColor: color ?? Theme.of(context).buttonTheme.colorScheme!.onPrimary,
    );

    final fontSize = MediaQuery.of(context).size.height * .0125 * (1.1);

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
