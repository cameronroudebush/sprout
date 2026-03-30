import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/category/widgets/category_dropdown.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/transaction/models/transaction_state.dart';
import 'package:sprout/transaction/transaction_provider.dart';

/// The filter bar placed at the top of the transactions page to allow you to be more intentional on
///   what data you want to see.
class TransactionFilterBar extends ConsumerStatefulWidget {
  final String? accountId;
  final VoidCallback onFilterChanged;

  const TransactionFilterBar({
    super.key,
    this.accountId,
    required this.onFilterChanged,
  });

  @override
  ConsumerState<TransactionFilterBar> createState() => _TransactionFilterBarState();
}

class _TransactionFilterBarState extends ConsumerState<TransactionFilterBar> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final currentSearch = ref.read(transactionFilterStateProvider).search;
    _searchController.text = currentSearch;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Updates the filter provider
  void _updateFilter(TransactionFilter newFilter) {
    ref.read(transactionFilterStateProvider.notifier).update(newFilter);
    widget.onFilterChanged();
  }

  /// What to do when the search input changes
  void _onSearchChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final filters = ref.read(transactionFilterStateProvider);
      _updateFilter(filters.copyWith(search: val));
    });
  }

  /// Applies a date preset from the dropdown
  void _applyDatePreset(String preset) async {
    final now = DateTime.now();
    DateTimeRange? range;
    final filters = ref.read(transactionFilterStateProvider);

    switch (preset) {
      case 'This Month':
        range = DateTimeRange(start: DateTime(now.year, now.month, 1), end: now);
        break;
      case 'Last Month':
        range = DateTimeRange(
          start: DateTime(now.year, now.month - 1, 1),
          end: DateTime(now.year, now.month, 0),
        );
        break;
      case 'Last Week':
        range = DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now);
        break;
      default:
        range = null;
    }
    _updateFilter(filters.copyWith(dateRange: range));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filters = ref.watch(transactionFilterStateProvider);
    final categories = ref.watch(categoriesProvider).value ?? [];
    final radius = BorderRadius.circular(4);

    final initialCategory =
        categories.firstWhereOrNull((c) => c.id == filters.categoryId) ?? CategoryDropdown.fakeAllCategory;

    // Search Component
    final searchField = TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search...',
        prefixIcon: const Icon(Icons.search, size: 20),
        isDense: true,
        border: OutlineInputBorder(borderRadius: radius),
      ),
      onChanged: _onSearchChanged,
    );

    // Date Menu Component
    final dateMenu = PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      menuPadding: EdgeInsets.zero,
      onSelected: _applyDatePreset,
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'All Time', child: Text('All Time')),
        const PopupMenuItem(value: 'This Month', child: Text('This Month')),
        const PopupMenuItem(value: 'Last Week', child: Text('Last Week')),
        const PopupMenuItem(value: 'Last Month', child: Text('Last Month')),
      ],
      child: IgnorePointer(
        child: OutlinedButton.icon(
          onPressed: () {}, // Handled by PopupMenuButton
          style: OutlinedButton.styleFrom(
            foregroundColor: filters.dateRange != null ? Colors.white : null,
            backgroundColor: filters.dateRange != null ? theme.colorScheme.primary : null,
            shape: RoundedRectangleBorder(borderRadius: radius),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          icon: Icon(filters.dateRange != null ? Icons.date_range : Icons.calendar_month, size: 18),
          label: Text(filters.dateRange == null ? "Date" : "Filtered"),
        ),
      ),
    );

    final resetVisible = filters.dateRange != null || filters.pending != null || filters.search.isNotEmpty;
    final resetButton = IconButton(
        onPressed: () {
          _searchController.clear();
          _updateFilter(TransactionFilter(accountId: widget.accountId));
        },
        icon: const Icon(Icons.refresh_rounded));

    return SproutLayoutBuilder((isDesktop, context, constraints) {
      final categoryDropdown = CategoryDropdown(
          initialCategory, (cat) => _updateFilter(filters.copyWith(categoryId: cat?.id)),
          displayAllCategoryButton: true);

      final isFiltered = filters.pending == true;
      final pendingChip = FilledButton(
        style: FilledButton.styleFrom(
            backgroundColor: !isFiltered ? theme.scaffoldBackgroundColor : theme.colorScheme.primary,
            foregroundColor: !isFiltered ? theme.colorScheme.onBackground : theme.colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(horizontal: 8),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: theme.colorScheme.onBackground, width: 1),
              borderRadius: radius,
            )),
        onPressed: () {
          final val = filters.pending == null ? true : false;
          filters.pending = val ? true : null;
          _updateFilter(filters);
        },
        child: Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [if (filters.pending == true) Icon(Icons.check), const Text("Pending")],
        ),
      );

      if (isDesktop) {
        return SproutCard(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              spacing: 12,
              children: [
                Expanded(flex: 3, child: searchField),
                Expanded(flex: 2, child: categoryDropdown),
                dateMenu,
                pendingChip,
                if (resetVisible) resetButton
              ],
            ),
          ),
        );
      }

      // Mobile
      return Column(
        spacing: 8,
        children: [
          Row(spacing: 8, children: [Expanded(child: searchField), Expanded(child: categoryDropdown)]),
          Row(
              spacing: 8,
              children: [Expanded(child: dateMenu), Expanded(child: pendingChip), if (resetVisible) resetButton]),
        ],
      );
    });
  }
}
