import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/category/widgets/dropdown.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/provider/snackbar.dart';
import 'package:sprout/core/widgets/dialog.dart';

/// A widget that displays the editing capabilities of a [Category]
class CategoryInfo extends StatefulWidget {
  final Category? category;

  /// When a category is added (because category was given as null) this will be called with the new one.
  final Function(Category category)? onAdd;
  const CategoryInfo(this.category, {super.key, this.onAdd});

  @override
  State<CategoryInfo> createState() => _CategoryInfoState();
}

class _CategoryInfoState extends State<CategoryInfo> {
  final categoryProvider = ServiceLocator.get<CategoryProvider>();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  CategoryTypeEnum _type = CategoryTypeEnum.expense;
  Category? _parentCategory;

  @override
  void initState() {
    super.initState();
    categoryProvider.loadUpdatedCategories();
    final category = widget.category;
    if (category != null) {
      // Initialize for editing an existing category
      _nameController.text = category.name;
      _type = category.type;
      _parentCategory = category.parentCategory;
    } else {
      // Initialize for a new category
      _nameController.text = "";
      _type = CategoryTypeEnum.expense; // Default value
      _parentCategory = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Returns the form fields as a new [Category] object
  Category _getNewCategory() {
    return Category(
      id: widget.category?.id ?? "",
      name: _nameController.text,
      type: _type,
      parentCategory: _parentCategory,
    );
  }

  /// Returns true if the value has changed from the original widget
  bool _valHasChanged(Category category) {
    if (widget.category == null) {
      return true; // Always true for a new category
    } else {
      final currentJson = widget.category!.toJson();
      final newCategoryJson = category.toJson();
      // Use DeepCollectionEquality to compare the maps
      return !const DeepCollectionEquality().equals(currentJson, newCategoryJson);
    }
  }

  Future<void> _submit() async {
    final isEdit = widget.category != null;
    final provider = ServiceLocator.get<CategoryProvider>();
    bool success = false;

    // Validate the form before proceeding with submission
    if (_formKey.currentState!.validate()) {
      final newCategory = _getNewCategory();

      if (!_valHasChanged(newCategory)) {
        // Don't submit if no changes, just exit
      } else if (isEdit) {
        // Tell provider to update the category
        await provider.edit(newCategory);
        success = true;
      } else {
        // Add a new category
        try {
          final createdCategory = await provider.add(newCategory);
          if (widget.onAdd != null && createdCategory != null) widget.onAdd!(createdCategory);
          success = true;
        } catch (e) {
          SnackbarProvider.openWithAPIException(e);
        }
      }

      // Close dialog
      if (success) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;
    // Create a temporary new category to check for changes
    final newCategory = _getNewCategory();

    return SproutDialogWidget(
      isEdit ? "Edit Category" : "Add Category",
      showCloseDialogButton: true,
      closeButtonText: "Cancel",
      showSubmitButton: true,
      // Enable submit button only if form is valid and there are changes
      allowSubmitClick: _valHasChanged(newCategory) && (_formKey.currentState?.validate() ?? false),
      onSubmitClick: _submit,
      child: _getForm(),
    );
  }

  Widget _getForm() {
    final helpStyle = TextStyle(fontSize: 12, color: Colors.grey[600]);

    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        return Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  // Category Name
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      const Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: "e.g., 'Groceries' or 'Salary'",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a name";
                          }
                          return null;
                        },
                        onChanged: (value) => setState(() {}),
                        onFieldSubmitted: (value) {
                          _submit();
                        },
                      ),
                    ],
                  ),

                  // Category Type
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      const Text("Type", style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButtonFormField<CategoryTypeEnum>(
                        dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        menuMaxHeight: MediaQuery.of(context).size.height * 0.5,
                        value: _type,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        items: CategoryTypeEnum.values.map((type) {
                          final typeName = type.toString();
                          return DropdownMenuItem(
                            value: type,
                            // Capitalize
                            child: Text(
                              typeName.split('.').last[0].toUpperCase() + typeName.split('.').last.substring(1),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() => _type = newValue);
                          }
                        },
                      ),
                      Text("Choose whether this is an income or expense category.", style: helpStyle),
                    ],
                  ),

                  // Parent Category
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      const Text("Parent Category", style: TextStyle(fontWeight: FontWeight.bold)),
                      CategoryDropdown(_parentCategory, (cat) {
                        setState(() {
                          _parentCategory = cat;
                        });
                      }),
                      Text("Assign a parent to create a sub-category.", style: helpStyle),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
