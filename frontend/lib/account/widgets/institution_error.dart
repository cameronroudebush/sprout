import 'package:flutter/material.dart';
import 'package:sprout/account/models/institution.dart';
import 'package:sprout/core/widgets/tooltip.dart';

/// Renders an indicator if the given institution has an error.
class InstitutionError extends StatelessWidget {
  final Institution? institution;

  /// A message to display instead of the institution error
  final String? overrideMessage;

  const InstitutionError({super.key, required this.institution, this.overrideMessage});

  @override
  Widget build(BuildContext context) {
    if (institution != null && institution!.hasError) {
      return SproutTooltip(
        message: overrideMessage ?? 'There was an error syncing with ${institution!.name}.',
        child: const Padding(
          padding: EdgeInsets.only(top: 4.0),
          child: Icon(Icons.warning, color: Colors.red, size: 20.0),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
