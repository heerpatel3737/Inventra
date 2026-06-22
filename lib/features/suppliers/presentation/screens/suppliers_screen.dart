import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../widgets/buttons/luxury_button.dart';
import '../../../../widgets/layouts/editorial_header.dart';
import '../../../../widgets/layouts/luxury_scaffold.dart';
import '../providers/suppliers_providers.dart';
import '../widgets/supplier_form_dialog.dart';

class SuppliersScreen extends ConsumerWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliers = ref.watch(suppliersProvider);

    return LuxuryScaffold(
      route: AppRoutes.suppliers,
      title: 'Supplier Network',
      header: const EditorialHeader(
        eyebrow: 'Strategic Partnerships',
        title: 'Supplier Intelligence Ledger',
        subtitle: 'Manage supplier records used in procurement and product forms.',
      ),
      children: [
        LuxuryButton(
          label: 'Add Supplier',
          icon: Icons.add_rounded,
          onPressed: () => openSupplierFormDialog(context),
        ),
        const SizedBox(height: 14),
        if (suppliers.isEmpty)
          const AppEmptyView(
            title: 'No suppliers yet',
            subtitle: 'Add suppliers to connect products and purchase workflows.',
            icon: Icons.groups_outlined,
          )
        else
          ...suppliers.map(
            (supplier) => Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: const CircleAvatar(child: Icon(Icons.business_outlined)),
                title: Text(supplier.name),
                subtitle: Text(
                  '${supplier.email}\n${supplier.phone}\n${supplier.address}\nStatus: ${supplier.status}',
                ),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (action) async {
                    if (action == 'edit') {
                      await openSupplierFormDialog(context, supplier: supplier);
                    } else if (action == 'delete') {
                      ref.read(suppliersProvider.notifier).deleteSupplier(supplier.id);
                      AppSnackbar.showSuccess(context, 'Supplier Deleted');
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
