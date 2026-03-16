import 'package:sprout/api/api.dart';

/// State object to hold both the list of rules and the loading status
class TransactionRuleState {
  final List<TransactionRule> rules;
  final bool isRunning;

  TransactionRuleState({required this.rules, this.isRunning = false});

  TransactionRuleState copyWith({List<TransactionRule>? rules, bool? isRunning}) {
    return TransactionRuleState(rules: rules ?? this.rules, isRunning: isRunning ?? this.isRunning);
  }
}
