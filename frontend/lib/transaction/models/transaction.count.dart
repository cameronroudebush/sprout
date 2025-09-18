/// Count of all total transactions
class TotalTransactions {
  final Map<String, int> accounts;
  final int total;

  TotalTransactions({required this.accounts, required this.total});

  factory TotalTransactions.fromJson(Map<String, dynamic> json) {
    return TotalTransactions(accounts: Map<String, int>.from(json['accounts']), total: json['total'] as int);
  }
}
