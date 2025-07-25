import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/models/account.dart'; // Assuming you have this model
import 'package:sprout/auth/api.dart';
import 'package:sprout/config/provider.dart';

/// A widget used to display an account logo
class AccountLogoWidget extends StatefulWidget {
  final Account account;

  const AccountLogoWidget({super.key, required this.account});

  @override
  State<AccountLogoWidget> createState() => _AccountLogoWidgetState();
}

class _AccountLogoWidgetState extends State<AccountLogoWidget> {
  String? _jwt;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJwt();
  }

  /// Asynchronously fetches the JWT from secure storage.
  Future<void> _fetchJwt() async {
    final configProvider = Provider.of<ConfigProvider>(context, listen: false);
    final String? fetchedJwt = await configProvider.api.secureStorage.getValue(AuthAPI.jwtKey);
    if (mounted) {
      setState(() {
        _jwt = fetchedJwt;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final configProvider = Provider.of<ConfigProvider>(context);
    final institution = widget.account.institution;
    final imageProxyURL = "${configProvider.baseUrl}/api/image-proxy?url=${institution.id}";

    return ClipRRect(
      borderRadius: BorderRadius.circular(24.0),
      child: SizedBox(
        width: 40,
        height: 40,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2.0))
            : Image.network(
                imageProxyURL,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(widget.account.fallbackIcon, size: 30.0);
                },
                headers: {if (_jwt != null) 'Authorization': 'Bearer $_jwt'},
              ),
      ),
    );
  }
}
