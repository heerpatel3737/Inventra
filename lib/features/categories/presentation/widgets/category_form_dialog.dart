import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_form_dialog.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../widgets/buttons/luxury_button.dart';
import '../../../../widgets/custom_textfield.dart';
import '../../../../models/category_model.dart';
import '../providers/categories_providers.dart';

class CategoryFormDialog extends ConsumerStatefulWidget {
  final CategoryModel? category;

  const CategoryFormDialog({super.key, this.category});

  @override
  ConsumerState<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  bool get isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descriptionController = TextEditingController(text: widget.category?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(categoriesProvider.notifier);
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (isEditing) {
      notifier.updateCategory(
        id: widget.category!.id,
        name: name,
        description: description,
      );
    } else {
      notifier.addCategory(name: name, description: description);
    }

    Navigator.pop(context, true);
    AppSnackbar.showSuccess(context, isEditing ? 'Category Updated' : 'Category Added');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            label: 'Category Name',
            icon: Icons.category_outlined,
            controller: _nameController,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Description (optional)',
            icon: Icons.notes_outlined,
            controller: _descriptionController,
            maxLines: 2,
            required: false,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LuxuryButton(
                  label: isEditing ? 'Update' : 'Save',
                  icon: Icons.check_rounded,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> openCategoryFormDialog(BuildContext context, {CategoryModel? category}) async {
  await showAppFormDialog(
    context: context,
    title: category == null ? 'Add Category' : 'Edit Category',
    child: CategoryFormDialog(category: category),
  );
}
