import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/spacing_constants.dart';
import '../../core/themes/color_palette.dart';
import '../providers/auth_controller.dart';
import '../widgets/animated_gradient_backdrop.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/fade_slide.dart';
import '../widgets/glass_card.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _identityController = TextEditingController();
  late AnimationController _shieldController;
  late Animation<double> _shieldBounce;

  @override
  void initState() {
    super.initState();
    _shieldController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _shieldBounce = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _shieldController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _identityController.dispose();
    _shieldController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
    final identifier = _identityController.text.trim();
    
    final success = await context.read<AuthController>().sendPasswordReset(identifier);
      
    if (success && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.bgCard
              : AppColors.white,
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_rounded,
                  color: AppColors.success,
                  size: 48,
                ),
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                'Cek Email Anda',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.white
                          : AppColors.deepNavy,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.md),
              Text(
                'Link reset password telah dikirim ke email Anda. Silakan cek kotak masuk (Inbox) atau folder Spam/Junk.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.xl),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Kembali ke Login',
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup dialog
                    Navigator.of(context).pop(); // Tutup halaman Forgot Password
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
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
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    // Animated shield icon header
                    FadeSlide(
                      child: AnimatedBuilder(
                        animation: _shieldBounce,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _shieldBounce.value),
                            child: child,
                          );
                        },
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.safetyOrange.withValues(alpha: 0.15)
                                : AppColors.safetyOrange.withValues(alpha: 0.10),
                            boxShadow: [
                              if (Theme.of(context).brightness != Brightness.dark)
                                BoxShadow(
                                  color: AppColors.safetyOrange.withValues(alpha: 0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                            ],
                          ),
                          child: const Icon(
                            Icons.lock_reset_rounded,
                            color: AppColors.safetyOrange,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),

                    // Title
                    FadeSlide(
                      delay: const Duration(milliseconds: 80),
                      child: Text(
                        'Reset Password',
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                        'Masukkan NIK atau email. Link reset akan\ndikirim melalui Firebase Auth.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),

                    // Form card
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
                              // Orange accent top bar
                              Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.safetyOrange,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              const SizedBox(height: Spacing.md),

                              if (auth.errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.error
                                        .withValues(alpha: 0.08),
                                    border: Border.all(
                                      color: AppColors.error
                                          .withValues(alpha: 0.25),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.error_outline_rounded,
                                        color: AppColors.error,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          auth.errorMessage!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.error,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: Spacing.md),
                              ],

                              AppTextField(
                                controller: _identityController,
                                label: 'NIK atau Email',
                                hint: '0000000000 atau user@domain.com',
                                icon: Icons.email_rounded,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _submit(),
                                validator: (value) {
                                  final raw = value?.trim() ?? '';
                                  final isNik =
                                      RegExp(r'^\d{10}$').hasMatch(raw);
                                  final isEmail = raw.contains('@') &&
                                      raw.contains('.');
                                  if (!isNik && !isEmail) {
                                    return 'Isi NIK 10 digit atau email valid';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: Spacing.md),

                              AppButton(
                                label: 'Kirim Link Reset',
                                icon: Icons.mark_email_read_outlined,
                                isLoading: auth.isBusy,
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
