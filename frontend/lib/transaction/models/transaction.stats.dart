/// A class that holds stats about transactions
class TransactionStats {
  final double totalSpend;
  final double totalIncome;
  final double averageTransactionCost;
  final double largestExpense;
  final Map<String, int> categories;

  TransactionStats({
    required this.totalSpend,
    required this.totalIncome,
    required this.averageTransactionCost,
    required this.largestExpense,
    required this.categories,
  });

  factory TransactionStats.fromJson(Map<String, dynamic> json) {
    return TransactionStats(
      totalSpend: (json['totalSpend'] as num).toDouble(),
      totalIncome: (json['totalIncome'] as num).toDouble(),
      averageTransactionCost: (json['averageTransactionCost'] as num).toDouble(),
      largestExpense: (json['largestExpense'] as num).toDouble(),
      categories: Map<String, int>.from(json['categories']),
    );
  }
}
