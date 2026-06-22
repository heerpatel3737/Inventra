import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_dropdown_field.dart';
import '../../../../shared/widgets/app_form_dialog.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../widgets/buttons/luxury_button.dart';
import '../../../../widgets/custom_textfield.dart';
import '../providers/sales_providers.dart';

class SaleFormDialog extends ConsumerStatefulWidget {
  const SaleFormDialog({super.key});

  @override
  ConsumerState<SaleFormDialog> createState() => _SaleFormDialogState();
}

class _SaleFormDialogState extends ConsumerState<SaleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _clientController = TextEditingController();
  final _amountController = TextEditingController();

  String? _status;

  @override
  void dispose() {
    _clientController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_status == null) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? -1;
    if (amount <= 0) {
      AppSnackbar.showError(context, 'Enter a valid amount.');
      return;
    }

    await ref.read(salesProvider.notifier).addSale(
          clientName: _clientController.text,
          amount: amount,
          status: _status!,
        );

    if (!mounted) return;

    Navigator.pop(context, true);
    AppSnackbar.showSuccess(context, 'Sale Added');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            label: 'Client Name',
            icon: Icons.person_outline_rounded,
            controller: _clientController,
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
            items: const ['Paid', 'Shipped', 'Pending'],
            onChanged: (value) => setState(() => _status = value),
            validator: (value) => value == null ? 'Please select status' : null,
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

Future<void> openSaleFormDialog(BuildContext context) {
  return showAppFormDialog(
    context: context,
    title: 'Record Sale',
    child: const SaleFormDialog(),
  );
}
