import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/spacing_constants.dart';
import '../providers/auth_controller.dart';
import '../providers/profile_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthController>().user;
    _nameController = TextEditingController(text: user?.name);
    _emailController = TextEditingController(text: user?.email);
    _phoneController = TextEditingController(text: user?.phone);
    context.read<ProfileProvider>().clearMessages();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    final userId = context.read<AuthController>().user?.userId;
    if (userId == null) return;

    final provider = context.read<ProfileProvider>();
    final updatedUser = await provider.updateProfile(
      userId: userId,
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
    );

    if (mounted && updatedUser != null) {
      context.read<AuthController>().updateUser(updatedUser);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.successMessage ?? 'Sukses'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else if (mounted && provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil'), elevation: 0),
      body: SingleChildScrollView(
        padding: Spacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _nameController,
                label: 'Nama Lengkap',
                hint: 'Masukkan nama Anda',
                icon: Icons.person_rounded,
                validator: (val) => val == null || val.length < 3 ? 'Nama minimal 3 karakter' : null,
              ),
              const SizedBox(height: Spacing.md),
              AppTextField(
                controller: _emailController,
                label: 'Email Aktif',
                hint: 'nama@domain.com',
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val != null && val.trim().isNotEmpty && !val.contains('@')) {
                    return 'Email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: Spacing.md),
              AppTextField(
                controller: _phoneController,
                label: 'Nomor HP',
                hint: 'Contoh: 08123456789',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: Spacing.xl),
              AppButton(
                label: 'Simpan',
                onPressed: provider.isSaving ? null : _save,
                isLoading: provider.isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
