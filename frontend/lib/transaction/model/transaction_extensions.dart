import 'package:sprout/api/api.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Extension on transactions
extension TransactionExtensions on Transaction {
  /// Returns time text either absolute or relative based on how old it is
  String get timeText {
    return DateTime.now().difference(posted).inDays > 3
        ? posted.toShort
        : timeago.format(posted);
  }
}
