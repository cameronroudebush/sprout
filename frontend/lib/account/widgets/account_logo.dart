import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/models/account.dart'; // Assuming you have this model
import 'package:sprout/config/provider.dart';

/// A widget used to display an account logo
class AccountLogoWidget extends StatelessWidget {
  final Account account;

  const AccountLogoWidget({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfigProvider>(
      builder: (context, configProvider, child) {
        final institution = account.institution;
        // Use the backend as our image proxy
        final imageProxyURL = "${configProvider.baseUrl}/image-proxy?url=${institution.id}";

        return ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(24.0),
          child: Image.network(
            width: 40,
            height: 40,
            imageProxyURL,
            errorBuilder: (context, error, stackTrace) {
              return Icon(account.fallbackIcon, size: 30.0);
            },
          ),
        );
      },
    );
  }
}
