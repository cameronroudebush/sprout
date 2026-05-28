import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/user/models/extensions/user_extensions.dart';

/// A widget that shows the given User's avatar information
class UserAvatar extends ConsumerWidget {
  final User? user;

  const UserAvatar(this.user, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return CircleAvatar(
      radius: 16,
      backgroundColor: theme.colorScheme.primary,
      child: Text(
        user?.prettyName[0].toUpperCase() ?? "",
        style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 12),
      ),
    );
  }
}
