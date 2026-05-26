import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/spacing_constants.dart';
import '../../core/themes/color_palette.dart';
import '../../domain/entities/registration_request.dart';
import '../providers/auth_controller.dart';
import '../widgets/animated_gradient_backdrop.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/fade_slide.dart';
import '../widgets/glass_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nikController = TextEditingController();
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _positionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nikController.dispose();
    _nameController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthController>().registerEmployee(
          RegistrationRequest(
            nik: _nikController.text,
            name: _nameController.text,
            department: _departmentController.text,
            position: _positionController.text,
            phone: _phoneController.text,
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E293B)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                if (Theme.of(context).brightness != Brightness.dark)
                  BoxShadow(
                    color: AppColors.deepNavy.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppColors.deepNavy,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AnimatedGradientBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: Spacing.screenPadding,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: FadeSlide(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Text(
                        'Buat Akun Baru',
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? AppColors.white
                                      : AppColors.deepNavy,
                                ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        'Akun baru otomatis dibuat sebagai Karyawan.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: Spacing.lg),

                      // Form card
                      GlassCard(
                        padding: const EdgeInsets.all(24),
                        borderRadius: 24,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Error
                              if (auth.errorMessage != null) ...[
                                _RegisterAlert(message: auth.errorMessage!),
                                const SizedBox(height: Spacing.md),
                              ],

                               // ─── Section: Data Diri ───────────
                              _SectionLabel(
                                label: 'Data Karyawan',
                                icon: Icons.person_rounded,
                              ),
                              const SizedBox(height: Spacing.sm),

                              AppTextField(
                                controller: _nikController,
                                label: 'NIK',
                                hint: '10 digit',
                                icon: Icons.badge_rounded,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                validator: _validateNik,
                              ),
                              const SizedBox(height: Spacing.md),
                              AppTextField(
                                controller: _nameController,
                                label: 'Nama Lengkap',
                                hint: 'Nama karyawan',
                                icon: Icons.person_rounded,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if ((value?.trim() ?? '').length < 3) {
                                    return 'Nama minimal 3 karakter';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: Spacing.md),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTextField(
                                      controller: _departmentController,
                                      label: 'Departemen',
                                      hint: 'Produksi',
                                      icon: Icons.business_rounded,
                                      textInputAction: TextInputAction.next,
                                      validator: _required,
                                    ),
                                  ),
                                  const SizedBox(width: Spacing.md),
                                  Expanded(
                                    child: AppTextField(
                                      controller: _positionController,
                                      label: 'Jabatan',
                                      hint: 'Operator',
                                      icon: Icons.work_rounded,
                                      textInputAction: TextInputAction.next,
                                      validator: _required,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: Spacing.md),
                              AppTextField(
                                controller: _phoneController,
                                label: 'No. HP (Opsional)',
                                hint: '08xxxxxxxxxx',
                                icon: Icons.phone_rounded,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                              ),

                              const SizedBox(height: Spacing.lg),

                              // ─── Section: Password ──────────
                              _SectionLabel(
                                label: 'Buat Password',
                                icon: Icons.lock_rounded,
                              ),
                              const SizedBox(height: Spacing.sm),

                              AppTextField(
                                controller: _passwordController,
                                label: 'Password',
                                hint: 'Minimal 6 karakter',
                                icon: Icons.lock_rounded,
                                obscureText: true,
                                textInputAction: TextInputAction.next,
                                validator: _validatePassword,
                              ),
                              const SizedBox(height: Spacing.md),
                              AppTextField(
                                controller: _confirmPasswordController,
                                label: 'Konfirmasi Password',
                                hint: 'Ulangi password',
                                icon: Icons.lock_reset_rounded,
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _submit(),
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'Konfirmasi password tidak sama';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: Spacing.lg),

                              AppButton(
                                label: 'Daftar Sekarang',
                                icon: Icons.person_add_alt_rounded,
                                isLoading: auth.isBusy,
                                onPressed: _submit,
                              ),
                              const SizedBox(height: Spacing.sm),
                              TextButton(
                                onPressed: auth.isBusy
                                    ? null
                                    : () => Navigator.of(context).pop(),
                                child: const Text('Sudah punya akun? Login'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validateNik(String? value) {
    if (!RegExp(r'^\d{10}$').hasMatch(value?.trim() ?? '')) {
      return 'NIK harus 10 digit angka';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  String? _required(String? value) {
    if ((value?.trim() ?? '').isEmpty) return 'Wajib diisi';
    return null;
  }
}

// ─────────────────────── Section Label ───────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.safetyOrange),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.safetyOrange,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
        ),
      ],
    );
  }
}

// ─────────────────────── Error Alert ───────────────────────
class _RegisterAlert extends StatelessWidget {
  const _RegisterAlert({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
