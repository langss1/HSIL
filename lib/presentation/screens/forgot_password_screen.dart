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
    final sent = await context.read<AuthController>().sendPasswordReset(
          _identityController.text,
        );
    if (sent && mounted) {
      Navigator.of(context).pop();
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
              color: Colors.white.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: Colors.white,
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
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.safetyOrange.withValues(alpha: 0.20),
                                AppColors.safetyOrange.withValues(alpha: 0.05),
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.safetyOrange.withValues(alpha: 0.30),
                              width: 2,
                            ),
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
                    const SizedBox(height: Spacing.xl),

                    // Form card
                    FadeSlide(
                      delay: const Duration(milliseconds: 180),
                      child: GlassCard(
                        padding: const EdgeInsets.all(24),
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
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.safetyOrange,
                                      Color(0xFFFFAA6B),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              const SizedBox(height: Spacing.lg),

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
                                icon: Icons.alternate_email_rounded,
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
                              const SizedBox(height: Spacing.lg),

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
