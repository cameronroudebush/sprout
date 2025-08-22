import 'package:flutter/material.dart';

/// A reusable button that helps with default sizing for mobile
class ButtonWidget extends StatelessWidget {
  final String? text;
  final IconData? icon;

  /// If given displays instead of the icon
  final Widget? image;
  final VoidCallback? onPressed;

  /// Minimum width
  final double minSize;

  /// Height to set
  final double? height;
  final Color? color;

  final ButtonStyle? style;

  final MainAxisAlignment mainAxisAlignment;

  final Widget? child;

  const ButtonWidget({
    super.key,
    this.text,
    this.image,
    this.icon,
    this.onPressed,
    this.minSize = double.infinity,
    this.color,
    this.height,
    this.style,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final dynamicHeightMultiplier = mediaQuery.size.height > 1200 ? 0.03 : 0.04;
    final ButtonStyle buttonStyle = (style ?? const ButtonStyle()).merge(
      ElevatedButton.styleFrom(
        minimumSize: Size(minSize, height ?? mediaQuery.size.height * dynamicHeightMultiplier),
        elevation: 5,
        backgroundColor: color ?? Theme.of(context).buttonTheme.colorScheme!.onPrimary,
      ),
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
        child: Row(
          mainAxisAlignment: mainAxisAlignment,
          children: [
            if (image != null) image!,
            Text(
              text!,
              style: TextStyle(fontSize: fontSize),
              textAlign: TextAlign.center,
            ),
            if (child != null) child!,
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
