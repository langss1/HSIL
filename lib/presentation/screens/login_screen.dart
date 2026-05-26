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
    if (_didHydrateRememberedNik) return;
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
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthController>().signIn(
          nik: _nikController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 900;

    return Scaffold(
      body: AnimatedGradientBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 64 : Spacing.md,
                vertical: Spacing.md,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 45,
                            child: _DesktopHeroPanel(),
                          ),
                          const SizedBox(width: 60),
                          Expanded(
                            flex: 55,
                            child: _LoginFormCard(
                              formKey: _formKey,
                              nikController: _nikController,
                              passwordController: _passwordController,
                              auth: auth,
                              onSubmit: _submit,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _MobileHeader(),
                          const SizedBox(height: Spacing.xl),
                          _LoginFormCard(
                            formKey: _formKey,
                            nikController: _nikController,
                            passwordController: _passwordController,
                            auth: auth,
                            onSubmit: _submit,
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

// ─────────────────────── Mobile Header ───────────────────────
class _MobileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FadeSlide(
      child: Column(
        children: [
          const AppLogoMark(size: 72),
          const SizedBox(height: Spacing.md),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.safetyOrange, Color(0xFFFFAA6B)],
            ).createShader(bounds),
            child: Text(
              AppConstants.appName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            'Sistem Absensi Terintegrasi',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── Desktop Hero ───────────────────────
class _DesktopHeroPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FadeSlide(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppLogoMark(size: 88),
          const SizedBox(height: Spacing.xl),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.safetyOrange, Color(0xFFFFAA6B)],
            ).createShader(bounds),
            child: Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
            ),
          ),
          const SizedBox(height: Spacing.md),
          Text(
            'Platform HRIS modern untuk\nmanajemen absensi pabrik.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.7,
                ),
          ),
          const SizedBox(height: Spacing.xl),
          _FeatureChips(),
        ],
      ),
    );
  }
}

class _FeatureChips extends StatelessWidget {
  final _features = const [
    (Icons.gps_fixed_rounded, 'GPS Validation'),
    (Icons.face_rounded, 'Face ID'),
    (Icons.shield_rounded, 'Secure Auth'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: _features.map((f) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.safetyOrange.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.safetyOrange.withValues(alpha: 0.20),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(f.$1, size: 14, color: AppColors.safetyOrange),
              const SizedBox(width: 6),
              Text(
                f.$2,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.safetyOrange,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────── Login Form Card ───────────────────────
class _LoginFormCard extends StatelessWidget {
  const _LoginFormCard({
    required this.formKey,
    required this.nikController,
    required this.passwordController,
    required this.auth,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nikController;
  final TextEditingController passwordController;
  final AuthController auth;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return FadeSlide(
      delay: const Duration(milliseconds: 100),
      child: GlassCard(
        padding: const EdgeInsets.all(28),
        borderRadius: 24,
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang',
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Masuk ke akun karyawan Anda',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Firebase status indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: auth.isFirebaseReady
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: auth.isFirebaseReady
                            ? AppColors.success.withValues(alpha: 0.25)
                            : AppColors.warning.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: auth.isFirebaseReady
                                ? AppColors.success
                                : AppColors.warning,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          auth.isFirebaseReady ? 'Live' : 'Demo',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: auth.isFirebaseReady
                                        ? AppColors.success
                                        : AppColors.warning,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: Spacing.lg),

              // Error message
              if (auth.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.md),
                  child: _ErrorBanner(message: auth.errorMessage!),
                ),

              // NIK field
              AppTextField(
                controller: nikController,
                label: 'NIK Karyawan',
                hint: '10 digit nomor induk',
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (!RegExp(r'^\d{10}$').hasMatch(value?.trim() ?? '')) {
                    return 'NIK harus 10 digit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: Spacing.md),

              // Password field
              AppTextField(
                controller: passwordController,
                label: 'Password',
                hint: 'Min. 6 karakter',
                icon: Icons.lock_outline_rounded,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onSubmit(),
                validator: (value) {
                  if ((value ?? '').length < 6) {
                    return 'Password min. 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: Spacing.md),

              // Remember me (modern toggle style)
              Row(
                children: [
                  GestureDetector(
                    onTap: () => auth.setRememberMe(!auth.rememberMe),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 42,
                      height: 24,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: auth.rememberMe
                            ? AppColors.safetyOrange
                            : AppColors.bgCardLight,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: auth.rememberMe
                              ? AppColors.safetyOrange
                              : AppColors.textSecondary
                                  .withValues(alpha: 0.30),
                          width: 1.5,
                        ),
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        alignment: auth.rememberMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Text(
                    'Ingat NIK saya',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // Login button
              AppButton(
                label: 'Masuk Sekarang',
                icon: Icons.login_rounded,
                isLoading: auth.isBusy,
                onPressed: auth.isBusy ? null : onSubmit,
              ),
              const SizedBox(height: Spacing.md),

              // Links
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: auth.isBusy
                        ? null
                        : () => Navigator.of(context)
                            .pushNamed(RouteConstants.register),
                    icon: const Icon(Icons.person_add_outlined, size: 15),
                    label: const Text('Buat akun'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.safetyOrange,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: auth.isBusy
                        ? null
                        : () => Navigator.of(context)
                            .pushNamed(RouteConstants.forgotPassword),
                    icon: const Icon(Icons.help_outline_rounded, size: 15),
                    label: const Text('Lupa password?'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: EdgeInsets.zero,
                    ),
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

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 18),
          const SizedBox(width: Spacing.sm),
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
