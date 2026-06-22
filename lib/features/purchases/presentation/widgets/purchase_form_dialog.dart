import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../suppliers/presentation/providers/suppliers_providers.dart';
import '../../../../shared/widgets/app_dropdown_field.dart';
import '../../../../shared/widgets/app_form_dialog.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../widgets/buttons/luxury_button.dart';
import '../../../../widgets/custom_textfield.dart';
import '../providers/purchases_providers.dart';

class PurchaseFormDialog extends ConsumerStatefulWidget {
  const PurchaseFormDialog({super.key});

  @override
  ConsumerState<PurchaseFormDialog> createState() => _PurchaseFormDialogState();
}

class _PurchaseFormDialogState extends ConsumerState<PurchaseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  String? _supplier;
  String? _status;
  int _deliveryDays = 3;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_supplier == null || _status == null) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? -1;
    if (amount <= 0) {
      AppSnackbar.showError(context, 'Enter a valid amount.');
      return;
    }

    await ref.read(purchasesProvider.notifier).addPurchase(
          supplierName: _supplier!,
          amount: amount,
          status: _status!,
          expectedDelivery: DateTime.now().add(Duration(days: _deliveryDays)),
        );

    if (!mounted) return;

    Navigator.pop(context, true);
    AppSnackbar.showSuccess(context, 'Purchase Added');
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = ref.watch(supplierOptionsProvider);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDropdownField(
            label: 'Supplier',
            hint: 'Select Supplier',
            value: _supplier,
            items: suppliers,
            onChanged: (value) => setState(() => _supplier = value),
            validator: (value) => value == null ? 'Please select a supplier' : null,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Amount',
            icon: Icons.attach_money_rounded,
            keyboardType: TextInputType.number,
            controller: _amountController,
          ),
          const SizedBox(height: 12),
          AppDropdownField(
            label: 'Status',
            hint: 'Select Status',
            value: _status,
            items: const ['Pending', 'Approved', 'Received', 'Cancelled'],
            onChanged: (value) => setState(() => _status = value),
            validator: (value) => value == null ? 'Please select status' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Expected delivery (days)'),
              const Spacer(),
              DropdownButton<int>(
                value: _deliveryDays,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('1 day')),
                  DropdownMenuItem(value: 3, child: Text('3 days')),
                  DropdownMenuItem(value: 7, child: Text('7 days')),
                  DropdownMenuItem(value: 14, child: Text('14 days')),
                ],
                onChanged: (value) => setState(() => _deliveryDays = value ?? _deliveryDays),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
              const SizedBox(width: 10),
              Expanded(child: LuxuryButton(label: 'Save', icon: Icons.check_rounded, onPressed: _submit)),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> openPurchaseFormDialog(BuildContext context) {
  return showAppFormDialog(
    context: context,
    title: 'Create Purchase Order',
    child: const PurchaseFormDialog(),
  );
}
