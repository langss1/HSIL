import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/spacing_constants.dart';
import '../providers/auth_controller.dart';
import '../providers/profile_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProfileProvider>().clearMessages();
  }

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    final email = context.read<AuthController>().user?.email;
    if (email == null) return;

    final provider = context.read<ProfileProvider>();
    final success = await provider.changePassword(
      email: email,
      oldPassword: _oldController.text,
      newPassword: _newController.text,
      confirmPassword: _confirmController.text,
    );

    if (mounted && success) {
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
      appBar: AppBar(title: const Text('Ubah Password'), elevation: 0),
      body: SingleChildScrollView(
        padding: Spacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _oldController,
                label: 'Password Lama',
                hint: 'Masukkan password lama',
                icon: Icons.lock_rounded,
                obscureText: true,
                validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: Spacing.md),
              AppTextField(
                controller: _newController,
                label: 'Password Baru',
                hint: 'Minimal 6 karakter',
                icon: Icons.lock_outline_rounded,
                obscureText: true,
                validator: (val) => val == null || val.length < 6 ? 'Minimal 6 karakter' : null,
              ),
              const SizedBox(height: Spacing.md),
              AppTextField(
                controller: _confirmController,
                label: 'Konfirmasi Password',
                hint: 'Ketik ulang password baru',
                icon: Icons.lock_outline_rounded,
                obscureText: true,
                validator: (val) {
                  if (val != _newController.text) return 'Password tidak sama';
                  return null;
                },
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
