import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../widgets/buttons/luxury_button.dart';
import '../../../../widgets/layouts/editorial_header.dart';
import '../../../../widgets/layouts/luxury_scaffold.dart';
import '../providers/categories_providers.dart';
import '../widgets/category_form_dialog.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesWithCountsProvider);

    return LuxuryScaffold(
      route: AppRoutes.categories,
      title: 'Category Library',
      header: const EditorialHeader(
        eyebrow: 'Inventory Architecture',
        title: 'Category Composition',
        subtitle: 'Manage taxonomy used across products, analytics, and filters.',
      ),
      children: [
        LuxuryButton(
          label: 'Add Category',
          icon: Icons.add_rounded,
          onPressed: () => openCategoryFormDialog(context),
        ),
        const SizedBox(height: 14),
        if (categories.isEmpty)
          const AppEmptyView(
            title: 'No categories yet',
            subtitle: 'Create your first category to organize products.',
            icon: Icons.category_outlined,
          )
        else
          ...categories.map(
            (category) => Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                leading: const CircleAvatar(child: Icon(Icons.category_outlined)),
                title: Text(category.name),
                subtitle: Text(
                  category.description.isEmpty
                      ? '${category.totalProducts} products'
                      : '${category.description} • ${category.totalProducts} products',
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (action) async {
                    if (action == 'edit') {
                      await openCategoryFormDialog(context, category: category);
                    } else if (action == 'delete') {
                      ref.read(categoriesProvider.notifier).deleteCategory(category.id);
                      AppSnackbar.showSuccess(context, 'Category Deleted');
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
