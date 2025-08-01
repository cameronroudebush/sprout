import 'package:flutter/material.dart';
import 'package:sprout/account/dialog/sync.dart';
import 'package:sprout/account/models/account.dart';
import 'package:sprout/core/widgets/button.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:url_launcher/url_launcher.dart';

/// A dialog that tells you to update your account linking if an error exists
class AccountErrorDialog extends StatefulWidget {
  final Account account;
  const AccountErrorDialog({super.key, required this.account});

  @override
  State<AccountErrorDialog> createState() => _AccountErrorDialogState();
}

class _AccountErrorDialogState extends State<AccountErrorDialog> with WidgetsBindingObserver {
  /// Flag to track if we've launched the URL and are expecting a return
  bool _launchedUrl = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the user comes back to the foreground, we can say that they have returned and fire an update
    if (state == AppLifecycleState.resumed && _launchedUrl) {
      _onUserReturn();
      _launchedUrl = false;
    }
  }

  /// Function to launch the URL in a browser.
  Future<void> _launchSimpleFinUrl() async {
    final Uri url = Uri.parse('https://beta-bridge.simplefin.org/my-account');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    } else {
      _launchedUrl = true;
    }
  }

  /// This function is called when the user returns to the app.
  Future<void> _onUserReturn() async {
    // Open another dialog asking if we want to resync
    await showDialog(context: context, builder: (_) => SyncDialog());
  }

  @override
  Widget build(BuildContext context) {
    final account = widget.account;
    final institution = widget.account.institution;
    return AlertDialog(
      title: Center(child: TextWidget(referenceSize: 2, text: '${institution.name} Error')),
      content: TextWidget(
        referenceSize: 1,
        text:
            'The account "${account.name}" has an error and needs to be updated. Click the button below to be taken to update it.',
      ),
      actions: <Widget>[
        Center(
          child: ButtonWidget(
            text: "Navigate to fix",
            minSize: MediaQuery.of(context).size.width * .4,
            onPressed: () {
              Navigator.of(context).pop();
              _launchSimpleFinUrl();
            },
          ),
        ),
      ],
    );
  }
}
