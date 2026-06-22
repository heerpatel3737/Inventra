import 'package:flutter/material.dart';

import '../../../../models/user_profile_model.dart';
import '../../../../shared/widgets/app_form_dialog.dart';
import '../../../../widgets/buttons/luxury_button.dart';
import '../../../../widgets/custom_textfield.dart';

class ProfileEditDialog extends StatefulWidget {
  final UserProfileModel profile;
  final void Function({
    required String name,
    required String email,
    required String role,
    required String phone,
    required String department,
  }) onSave;

  const ProfileEditDialog({
    super.key,
    required this.profile,
    required this.onSave,
  });

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _roleController;
  late final TextEditingController _phoneController;
  late final TextEditingController _departmentController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _emailController = TextEditingController(text: widget.profile.email);
    _roleController = TextEditingController(text: widget.profile.role);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _departmentController = TextEditingController(text: widget.profile.department);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    widget.onSave(
      name: _nameController.text,
      email: _emailController.text,
      role: _roleController.text,
      phone: _phoneController.text,
      department: _departmentController.text,
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(label: 'Full Name', icon: Icons.person_outline, controller: _nameController),
          const SizedBox(height: 12),
          CustomTextField(label: 'Email', icon: Icons.email_outlined, controller: _emailController),
          const SizedBox(height: 12),
          CustomTextField(label: 'Role', icon: Icons.badge_outlined, controller: _roleController),
          const SizedBox(height: 12),
          CustomTextField(label: 'Phone', icon: Icons.phone_outlined, controller: _phoneController, required: false),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Department',
            icon: Icons.apartment_outlined,
            controller: _departmentController,
            required: false,
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

Future<void> openProfileEditDialog(
  BuildContext context, {
  required UserProfileModel profile,
  required void Function({
    required String name,
    required String email,
    required String role,
    required String phone,
    required String department,
  }) onSave,
}) {
  return showAppFormDialog(
    context: context,
    title: 'Edit Profile',
    child: ProfileEditDialog(profile: profile, onSave: onSave),
  );
}
