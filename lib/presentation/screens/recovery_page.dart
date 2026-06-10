import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/constants/spacing_constants.dart';
import '../../core/themes/color_palette.dart';
import '../widgets/animated_gradient_backdrop.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/fade_slide.dart';
import '../widgets/glass_card.dart';

class RecoveryPage extends StatefulWidget {
  const RecoveryPage({super.key, required this.nik, required this.otp});
  
  final String nik;
  final String otp;

  @override
  State<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isBusy = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    FocusScope.of(context).unfocus();
    
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });
    
    try {
      final functions = FirebaseFunctions.instance;
      await functions.httpsCallable('verifyOtpAndResetPassword').call({
        'nik': widget.nik,
        'otp': widget.otp,
        'newPassword': _passwordController.text,
      });

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password berhasil diubah. Silakan login kembali.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Go back to Login (pop until first)
      Navigator.of(context).popUntil((route) => route.isFirst);
      
    } on FirebaseFunctionsException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Gagal mengubah password.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan jaringan atau server.';
      });
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    FadeSlide(
                      child: Text(
                        'Buat Password Baru',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.white
                                  : AppColors.deepNavy,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    FadeSlide(
                      delay: const Duration(milliseconds: 120),
                      child: Text(
                        'Silakan masukkan password baru Anda.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),
                    FadeSlide(
                      delay: const Duration(milliseconds: 180),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 24,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(alpha: 0.08),
                                    border: Border.all(
                                      color: AppColors.error.withValues(alpha: 0.25),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _errorMessage!,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: Spacing.md),
                              ],
                              AppTextField(
                                controller: _passwordController,
                                label: 'Password Baru',
                                hint: 'Min. 6 karakter',
                                icon: Icons.lock_rounded,
                                obscureText: true,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if ((value?.trim() ?? '').length < 6) {
                                    return 'Password min. 6 karakter';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: Spacing.md),
                              AppTextField(
                                controller: _confirmController,
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
                                label: 'Simpan & Selesai',
                                icon: Icons.check_circle_outline_rounded,
                                isLoading: _isBusy,
                                onPressed: _submit,
                              ),
                            ],
                          ),
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
    );
  }
}
