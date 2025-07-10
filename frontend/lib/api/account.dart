import 'package:sprout/api/client.dart';

// TODO: Define account model
// // Define your Account model
// class Account {
//   final String name;
//   final double balance;
//   final IconData icon; // Assuming your Account model has an icon field

//   Account({required this.name, required this.balance, required this.icon});

//   // Example factory constructor to parse from API response (Map<String, dynamic>)
//   factory Account.fromJson(Map<String, dynamic> json) {
//     // You'll need to map your API's icon string to an actual IconData
//     // This is a placeholder for demonstration
//     IconData defaultIcon = Icons.account_balance;
//     if (json['type'] == 'checking') {
//       defaultIcon = Icons.account_balance;
//     } else if (json['type'] == 'savings') {
//       defaultIcon = Icons.savings;
//     } else if (json['type'] == 'credit_card') {
//       defaultIcon = Icons.credit_card;
//     } else if (json['type'] == 'investment') {
//       defaultIcon = Icons.trending_up;
//     }

//     return Account(
//       name: json['name'] as String,
//       balance: (json['balance'] as num).toDouble(),
//       icon: defaultIcon, // Replace with actual icon logic based on your API
//     );
//   }
// }

/// Class that provides callable endpoints for the accounts
class AccountAPI {
  /// Base URL of the sprout backend API
  RESTClient client;

  AccountAPI(this.client);

  /// Returns the accounts
  Future<dynamic> getAccounts() async {
    final endpoint = "/account/get/all";
    final body = {};

    try {
      dynamic result = await client.post(body, endpoint);

      print(result);
      // TODO: Cleanup
      return [
        {
          'name': 'Investment Portfolio',
          'balance': 21361.92,
          'type': 'Investment',
        },
      ];
    } catch (e) {
      return [];
    }
  }
}
