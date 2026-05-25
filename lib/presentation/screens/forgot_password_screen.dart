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

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identityController = TextEditingController();

  @override
  void dispose() {
    _identityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
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
      appBar: AppBar(),
      body: AnimatedGradientBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: Spacing.screenPadding,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: FadeSlide(
                  child: GlassCard(
                    padding: const EdgeInsets.all(22),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reset password',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: Spacing.sm),
                          Text(
                            'Masukkan NIK atau email akun. Link reset akan dikirim melalui Firebase Auth.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: Spacing.lg),
                          if (auth.errorMessage != null) ...[
                            Text(
                              auth.errorMessage!,
                              style: const TextStyle(color: AppColors.error),
                            ),
                            const SizedBox(height: Spacing.md),
                          ],
                          AppTextField(
                            controller: _identityController,
                            label: 'NIK atau email',
                            hint: '0000000000 atau user@domain.com',
                            icon: Icons.alternate_email_rounded,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(),
                            validator: (value) {
                              final raw = value?.trim() ?? '';
                              final isNik = RegExp(r'^\d{10}$').hasMatch(raw);
                              final isEmail =
                                  raw.contains('@') && raw.contains('.');
                              if (!isNik && !isEmail) {
                                return 'Isi NIK 10 digit atau email valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: Spacing.lg),
                          AppButton(
                            label: 'Kirim link reset',
                            icon: Icons.mark_email_read_outlined,
                            isLoading: auth.isBusy,
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
