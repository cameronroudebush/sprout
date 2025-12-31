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
    return SearchAnchor(
      builder: (BuildContext context, SearchController controller) {
        return InputDecorator(
          decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
          child: InkWell(
            onTap: () => controller.openView(),
            child: Row(
              spacing: 12,
              children: [
                CategoryIcon(
                  Category(id: "", name: "", type: CategoryTypeEnum.income, icon: icon ?? "help"),
                  avatarSize: 16,
                ),
                Text(icon ?? 'Select an icon'),
                const Spacer(),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        );
      },
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        final String searchTerm = controller.text.toLowerCase();

        // Filter icons based on search text
        final filteredIcons = CategoryIcon.iconLibrary.entries.where((entry) {
          return entry.key.contains(searchTerm);
        }).toList();

        return filteredIcons.map((entry) {
          return ListTile(
            leading: Icon(entry.value),
            title: Text(entry.key),
            onTap: () {
              onChanged(entry.key);
              controller.closeView(entry.key);
            },
          );
        });
      },
    );
  }
}
