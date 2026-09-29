import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/shared/widgets/month_navigation.dart';

/// Opens the shared month-and-year picker, capped at [maxMonth].
Future<DateTime?> showMonthPickerDialog({
  required BuildContext context,
  required DateTime selectedMonth,
  DateTime? maxMonth,
}) async {
  final latestMonth = MonthNavigation.normalize(maxMonth ?? DateTime.now());
  var pickerYear = selectedMonth.year;

  final pickedMonth = await showSproutPopup<DateTime>(
    context: context,
    builder: (dialogContext) => SproutBaseDialogWidget(
      'Choose a month',
      showCloseDialogButton: true,
      closeButtonText: 'Cancel',
      child: SizedBox(
          width: 360,
          height: 300,
          child: StatefulBuilder(
            builder: (context, setDialogState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => setDialogState(() => pickerYear--),
                      icon: const Icon(Icons.chevron_left),
                      tooltip: 'Previous year',
                    ),
                    Text('$pickerYear',
                        style: Theme.of(context).textTheme.titleMedium),
                    IconButton(
                      onPressed: pickerYear < latestMonth.year
                          ? () => setDialogState(() => pickerYear++)
                          : null,
                      icon: const Icon(Icons.chevron_right),
                      tooltip: 'Next year',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.2,
                  children: List.generate(12, (index) {
                    final targetMonth = DateTime(pickerYear, index + 1);
                    final selected =
                        MonthNavigation.isSameMonth(targetMonth, selectedMonth);
                    final isFuture =
                        MonthNavigation.isAfter(targetMonth, latestMonth);
                    return FilledButton.tonal(
                      onPressed: isFuture
                          ? null
                          : () => Navigator.of(dialogContext).pop(targetMonth),
                      style: FilledButton.styleFrom(
                        backgroundColor: selected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        foregroundColor: selected
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : null,
                      ),
                      child: Text(DateFormat('MMM').format(targetMonth)),
                    );
                  }),
                ),
              ],
            ),
          )),
    ),
  );

  if (pickedMonth != null &&
      MonthNavigation.isAfter(pickedMonth, latestMonth)) {
    return null;
  }
  return pickedMonth;
}

/// Opens a year picker that cannot select a year after [maxYear].
Future<int?> showYearPickerDialog({
  required BuildContext context,
  required int selectedYear,
  int? maxYear,
}) async {
  final latestYear = maxYear ?? DateTime.now().year;
  final boundedSelectedYear = selectedYear.clamp(1, latestYear).toInt();
  var firstYear = ((boundedSelectedYear - 1) ~/ 12) * 12 + 1;
  final lastPageFirstYear = ((latestYear - 1) ~/ 12) * 12 + 1;

  return showSproutPopup<int>(
    context: context,
    builder: (dialogContext) => SproutBaseDialogWidget(
      'Choose a year',
      showCloseDialogButton: true,
      closeButtonText: 'Cancel',
      child: SizedBox(
        width: 360,
        height: 300,
        child: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: firstYear > 1
                        ? () => setDialogState(() => firstYear -= 12)
                        : null,
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Previous years',
                  ),
                  Text(
                    '$firstYear–${(firstYear + 11).clamp(firstYear, latestYear)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    onPressed: firstYear + 12 <= lastPageFirstYear
                        ? () => setDialogState(() => firstYear += 12)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Next years',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.2,
                children: List.generate(12, (index) {
                  final year = firstYear + index;
                  final selected = year == boundedSelectedYear;
                  final isFuture = year > latestYear;
                  return FilledButton.tonal(
                    onPressed: isFuture
                        ? null
                        : () => Navigator.of(dialogContext).pop(year),
                    style: FilledButton.styleFrom(
                      backgroundColor: selected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      foregroundColor: selected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : null,
                    ),
                    child: Text('$year'),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
