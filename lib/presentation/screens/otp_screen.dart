import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../core/constants/spacing_constants.dart';
import '../../core/themes/color_palette.dart';
import '../widgets/animated_gradient_backdrop.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/fade_slide.dart';
import '../widgets/glass_card.dart';
import 'recovery_page.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.nik});
  
  final String nik;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isBusy = false;
  String? _errorMessage;

  @override
  void dispose() {
    _otpController.dispose();
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
      // Validate OTP is 6 digits before navigating
      final otp = _otpController.text.trim();
      if (otp.length != 6) {
        throw Exception('Kode OTP harus 6 digit');
      }
      
      // We don't call verify here, we pass it to RecoveryPage to verify WITH the new password
      // Because our Cloud Function verifyOtpAndResetPassword requires the new password.
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => RecoveryPage(nik: widget.nik, otp: otp),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
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
                        'Verifikasi OTP',
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
                        'Masukkan kode OTP 6-digit yang telah\ndikirim ke email Anda.',
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
                                controller: _otpController,
                                label: 'Kode OTP',
                                hint: '123456',
                                icon: Icons.password_rounded,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _submit(),
                                validator: (value) {
                                  if ((value?.trim() ?? '').length != 6) {
                                    return 'Harus 6 digit';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: Spacing.md),
                              AppButton(
                                label: 'Lanjut',
                                icon: Icons.arrow_forward_rounded,
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
