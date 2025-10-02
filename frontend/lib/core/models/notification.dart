import 'package:flutter/material.dart';

/// A class that allows us to display a notification message on the home page
class HomeNotification {
  /// The message to display
  String message;

  /// An icon to display for this notification
  IconData? icon;

  /// What to do if this notification is clicked
  VoidCallback? onClick;

  /// The background color of this notification
  Color bgColor;

  /// The text color of this notification
  Color color;

  HomeNotification(this.message, this.bgColor, this.color, {this.icon, this.onClick});
}
