import 'package:flutter/material.dart';
import '../../core/themes/color_palette.dart';

/// Premium gradient button with glow effect and animated press state
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isOutlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isOutlined;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = _scaleController;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _scaleController.reverse();
  void _onTapUp(TapUpDetails _) => _scaleController.forward();
  void _onTapCancel() => _scaleController.forward();

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    final buttonChild = AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: widget.isLoading
          ? const SizedBox(
              key: ValueKey('loading'),
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: AppColors.white,
              ),
            )
          : Row(
              key: const ValueKey('content'),
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 20),
                  const SizedBox(width: 10),
                ],
                Text(widget.label),
              ],
            ),
    );

    if (widget.isOutlined) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: isDisabled ? null : _onTapDown,
          onTapUp: isDisabled ? null : _onTapUp,
          onTapCancel: isDisabled ? null : _onTapCancel,
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: widget.isLoading ? null : widget.onPressed,
              child: buttonChild,
            ),
          ),
        ),
      );
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: isDisabled ? null : _onTapDown,
        onTapUp: isDisabled ? null : _onTapUp,
        onTapCancel: isDisabled ? null : _onTapCancel,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: isDisabled
                ? null
                : const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.safetyOrange,
                      Color(0xFFE85A23),
                    ],
                  ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: isDisabled
                ? null
                : [
                    BoxShadow(
                      color: AppColors.safetyOrange.withValues(alpha: 0.20),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDisabled ? null : Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
            ),
            child: buttonChild,
          ),
        ),
      ),
    );
  }
}
