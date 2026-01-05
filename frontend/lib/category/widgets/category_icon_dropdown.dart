import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/widgets/category_icon.dart';

/// This widget provides a way to select a meaningful icon to use alongside a category.
class CategoryIconDropdown extends StatelessWidget {
  final String? icon;
  final Function(String? newValue) onChanged;

  const CategoryIconDropdown(this.icon, this.onChanged, {super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return DropdownMenu<String>(
      initialSelection: icon,
      menuHeight: media.height * .4,
      expandedInsets: EdgeInsets.zero,
      enableFilter: true,
      requestFocusOnTap: true,
      leadingIcon: Padding(
        padding: EdgeInsetsGeometry.directional(start: 18, end: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CategoryIcon(
              Category(id: "", name: "", type: CategoryTypeEnum.income, icon: icon ?? "help"),
              avatarSize: 14,
            ),
          ],
        ),
      ),
      onSelected: (String? value) {
        if (value != null) {
          onChanged(value);
        }
      },
      dropdownMenuEntries: CategoryIcon.iconLibrary.entries.map((entry) {
        return DropdownMenuEntry<String>(value: entry.key, label: entry.key, leadingIcon: Icon(entry.value));
      }).toList(),
    );
  }
}
