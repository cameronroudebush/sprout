import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/widgets/account_icon.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/widgets/category_dropdown.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/transaction/widgets/website_icon.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionConfigCard extends ConsumerWidget {
  final Transaction transaction;
  final String? categoryId;
  final DateTime postedDate;
  final bool isEditable;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<DateTime> onDateChanged;

  const TransactionConfigCard({
    super.key,
    required this.transaction,
    required this.categoryId,
    required this.postedDate,
    required this.isEditable,
    required this.onCategoryChanged,
    required this.onDateChanged,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: postedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && context.mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(postedDate),
      );

      if (pickedTime != null) {
        onDateChanged(
          DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accounts = ref.watch(accountsProvider).value?.accounts;
    final account = accounts?.firstWhereOrNull((a) => a.id == transaction.accountId);
    final websiteUrl = transaction.extra?.website;

    final Uri? parsedUri = websiteUrl != null && websiteUrl.isNotEmpty
        ? Uri.tryParse(websiteUrl.startsWith('http') ? websiteUrl : 'https://$websiteUrl')
        : null;
    final displayDomain = parsedUri?.host.replaceFirst(RegExp(r'^www\.'), '') ?? websiteUrl;

    return SproutCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          spacing: 8,
          children: [
            if (account != null) ...[
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text("Account", style: theme.textTheme.titleSmall),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () => NavigationProvider.redirectToAccount(account),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 8,
                            children: [
                              AccountIcon(account, size: 20),
                              Flexible(
                                child: Text(
                                  account.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.open_in_new,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
            ],
            Row(
              spacing: 8,
              children: [
                Expanded(
                  flex: 2,
                  child: Text("Category", style: theme.textTheme.titleSmall),
                ),
                Expanded(
                  flex: 1,
                  child: CategoryDropdown(
                    categoryId,
                    (cat) => onCategoryChanged(cat?.id),
                    enabled: !transaction.pending,
                    label: "",
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: Text("Posted Date", style: theme.textTheme.titleSmall),
                ),
                InkWell(
                  onTap: isEditable ? () => _selectDate(context) : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Text(
                          DateFormat("MMM d, yyyy 'at' h:mm a").format(postedDate),
                          style: theme.textTheme.bodyMedium,
                        ),
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: isEditable ? theme.colorScheme.primary : theme.disabledColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (websiteUrl != null && websiteUrl.isNotEmpty) ...[
              const Divider(),
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: Text("Website", style: theme.textTheme.titleSmall),
                  ),
                  InkWell(
                    onTap: () async {
                      if (parsedUri != null) {
                        await launchUrl(parsedUri, mode: LaunchMode.externalApplication);
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          WebsiteIconWidget(websiteUrl: websiteUrl, size: 20),
                          if (displayDomain != null)
                            Text(
                              displayDomain,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          Icon(
                            Icons.open_in_new,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
