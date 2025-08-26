import 'package:flutter/material.dart';
import 'package:sprout/account/models/account.dart';
import 'package:sprout/core/widgets/text.dart';

/// A page that displays information about the current account
class AccountWidget extends StatelessWidget {
  /// The account we must have data from
  final Account account;

  const AccountWidget(this.account, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [TextWidget(text: account.name)]);
  }
}


// if (account.institution.hasError)
//                           Expanded(
//                             child: SproutTooltip(
//                               message: "Opens a page to fix this account.",
//                               child: ButtonWidget(
//                                 text: "Fix Account",
//                                 onPressed: () async {
//                                   await showDialog(
//                                     context: context,
//                                     builder: (_) => AccountErrorDialog(account: account),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                         Expanded(
//                           child: ButtonWidget(
//                             text: "Delete",
//                             color: theme.colorScheme.error,
//                             onPressed: () async {
//                               await showDialog(
//                                 context: context,
//                                 builder: (_) => AccountDeleteDialog(account: account),
//                               );
//                             },
//                           ),
//                         ),