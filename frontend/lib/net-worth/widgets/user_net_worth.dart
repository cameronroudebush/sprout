import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';
import 'package:sprout/net-worth/widgets/generic_net_worth.dart';

/// A net worth widget that displays the users overall net worth across all accounts
class UserNetWorthWidget extends ConsumerWidget {
  final String? title;
  final bool invert;

  const UserNetWorthWidget({
    super.key,
    this.title = "Net Worth",
    this.invert = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GenericNetWorthWidget<TotalNetWorthDTO>(
      title: title,
      invert: invert,
      chartHeight: 150,
      data: ref.watch(totalNetWorthProvider),
      getValue: (dto) => dto.value,
      getHistory: (dto) => dto.history,
      getTimeline: (dto) => dto.timeline,
    );
  }
}
