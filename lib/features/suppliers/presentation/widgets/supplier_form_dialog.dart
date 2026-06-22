import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/supplier_model.dart';
import '../../../../shared/widgets/app_dropdown_field.dart';
import '../../../../shared/widgets/app_form_dialog.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../widgets/buttons/luxury_button.dart';
import '../../../../widgets/custom_textfield.dart';
import '../providers/suppliers_providers.dart';

class SupplierFormDialog extends ConsumerStatefulWidget {
  final SupplierModel? supplier;

  const SupplierFormDialog({super.key, this.supplier});

  @override
  ConsumerState<SupplierFormDialog> createState() => _SupplierFormDialogState();
}

class _SupplierFormDialogState extends ConsumerState<SupplierFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  String? _status;

  bool get isEditing => widget.supplier != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier?.name ?? '');
    _phoneController = TextEditingController(text: widget.supplier?.phone ?? '');
    _emailController = TextEditingController(text: widget.supplier?.email ?? '');
    _addressController = TextEditingController(text: widget.supplier?.address ?? '');
    _status = widget.supplier?.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_status == null) return;

    final notifier = ref.read(suppliersProvider.notifier);

    if (isEditing) {
      notifier.updateSupplier(
        id: widget.supplier!.id,
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        address: _addressController.text,
        status: _status!,
      );
    } else {
      notifier.addSupplier(
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        address: _addressController.text,
        status: _status!,
      );
    }

    Navigator.pop(context, true);
    AppSnackbar.showSuccess(context, isEditing ? 'Supplier Updated' : 'Supplier Added');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(label: 'Supplier Name', icon: Icons.business_outlined, controller: _nameController),
          const SizedBox(height: 12),
          CustomTextField(label: 'Phone Number', icon: Icons.phone_outlined, controller: _phoneController, keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          CustomTextField(label: 'Email', icon: Icons.email_outlined, controller: _emailController, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          CustomTextField(label: 'Address', icon: Icons.location_on_outlined, controller: _addressController, maxLines: 2),
          const SizedBox(height: 12),
          AppDropdownField(
            label: 'Status',
            hint: 'Select Status',
            value: _status,
            items: const ['Active', 'Inactive'],
            onChanged: (value) => setState(() => _status = value),
            validator: (value) => value == null ? 'Please select status' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
              const SizedBox(width: 10),
              Expanded(child: LuxuryButton(label: isEditing ? 'Update' : 'Save', icon: Icons.check_rounded, onPressed: _submit)),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> openSupplierFormDialog(BuildContext context, {SupplierModel? supplier}) async {
  await showAppFormDialog(
    context: context,
    title: supplier == null ? 'Add Supplier' : 'Edit Supplier',
    child: SupplierFormDialog(supplier: supplier),
  );
}
