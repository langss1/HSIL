import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/route_constants.dart';
import '../../core/constants/spacing_constants.dart';
import '../../core/themes/color_palette.dart';
import '../providers/auth_controller.dart';
import '../widgets/animated_gradient_backdrop.dart';
import '../widgets/app_button.dart';
import '../widgets/app_logo_mark.dart';
import '../widgets/app_text_field.dart';
import '../widgets/fade_slide.dart';
import '../widgets/glass_card.dart';
import '../widgets/status_pill.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nikController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _didHydrateRememberedNik = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didHydrateRememberedNik) {
      return;
    }
    final rememberedNik = context.read<AuthController>().rememberedNik;
    if (rememberedNik != null) {
      _nikController.text = rememberedNik;
    }
    _didHydrateRememberedNik = true;
  }

  @override
  void dispose() {
    _nikController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await context.read<AuthController>().signIn(
      nik: _nikController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 760;

    return Scaffold(
      body: AnimatedGradientBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 48 : Spacing.md,
                vertical: Spacing.xl,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child:
                    isWide
                        ? Row(
                          children: [
                            const Expanded(child: _HeroPanel()),
                            const SizedBox(width: Spacing.xl),
                            Expanded(child: _loginCard(auth: auth)),
                          ],
                        )
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _HeroPanel(compact: true),
                            const SizedBox(height: Spacing.lg),
                            _loginCard(auth: auth),
                          ],
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginCard({required AuthController auth}) {
    return FadeSlide(
      delay: const Duration(milliseconds: 120),
      child: GlassCard(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Masuk', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: Spacing.sm),
              Text(
                'Gunakan NIK dan password untuk membuka dashboard.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: Spacing.lg),
              if (auth.firebaseMessage != null) ...[
                StatusPill(
                  label:
                      auth.isFirebaseReady
                          ? 'Firebase ready'
                          : 'Firebase offline fallback',
                  icon:
                      auth.isFirebaseReady
                          ? Icons.cloud_done_rounded
                          : Icons.cloud_off_rounded,
                  color:
                      auth.isFirebaseReady
                          ? AppColors.success
                          : AppColors.warning,
                ),
                const SizedBox(height: Spacing.md),
              ],
              if (auth.errorMessage != null) ...[
                _InlineAlert(
                  message: auth.errorMessage!,
                  color: AppColors.error,
                  icon: Icons.error_outline_rounded,
                ),
                const SizedBox(height: Spacing.md),
              ],
              if (auth.infoMessage != null) ...[
                _InlineAlert(
                  message: auth.infoMessage!,
                  color: AppColors.info,
                  icon: Icons.info_outline_rounded,
                ),
                const SizedBox(height: Spacing.md),
              ],
              AppTextField(
                controller: _nikController,
                label: 'NIK',
                hint: '10 digit NIK',
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final nik = value?.trim() ?? '';
                  if (!RegExp(r'^\d{10}$').hasMatch(nik)) {
                    return 'NIK harus 10 digit angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: Spacing.md),
              AppTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Minimal 6 karakter',
                icon: Icons.lock_outline_rounded,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                validator: (value) {
                  if ((value ?? '').length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: Spacing.sm),
              Row(
                children: [
                  Checkbox(
                    value: auth.rememberMe,
                    onChanged:
                        (value) =>
                            auth.setRememberMe(value ?? !auth.rememberMe),
                  ),
                  Expanded(
                    child: Text(
                      'Remember Me (simpan NIK, bukan password)',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              AppButton(
                label: 'Login',
                icon: Icons.login_rounded,
                isLoading: auth.isBusy,
                onPressed: _submit,
              ),
              const SizedBox(height: Spacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed:
                        auth.isBusy
                            ? null
                            : () => Navigator.of(
                              context,
                            ).pushNamed(RouteConstants.register),
                    child: const Text('Buat akun'),
                  ),
                  TextButton(
                    onPressed:
                        auth.isBusy
                            ? null
                            : () => Navigator.of(
                              context,
                            ).pushNamed(RouteConstants.forgotPassword),
                    child: const Text('Lupa password?'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return FadeSlide(
      child: Column(
        crossAxisAlignment:
            compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          const AppLogoMark(),
          const SizedBox(height: Spacing.lg),
          Text(
            AppConstants.appName,
            textAlign: compact ? TextAlign.center : TextAlign.start,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: Spacing.md),
          Text(
            'Absensi pabrik yang jelas, cepat, dan rapi untuk employee maupun admin.',
            textAlign: compact ? TextAlign.center : TextAlign.start,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          if (!compact) ...[
            const SizedBox(height: Spacing.lg),
            const Wrap(
              spacing: Spacing.sm,
              runSpacing: Spacing.sm,
              children: [
                StatusPill(
                  label: 'Role access',
                  icon: Icons.admin_panel_settings_rounded,
                  color: AppColors.safetyOrange,
                ),
                StatusPill(
                  label: 'Session cache',
                  icon: Icons.sync_rounded,
                  color: AppColors.info,
                ),
                StatusPill(
                  label: 'Firebase ready',
                  icon: Icons.shield_rounded,
                  color: AppColors.success,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InlineAlert extends StatelessWidget {
  const _InlineAlert({
    required this.message,
    required this.color,
    required this.icon,
  });

  final String message;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
