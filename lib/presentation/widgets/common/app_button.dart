import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'app_text.dart';

enum AppButtonType { primary, outlined, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double height;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height = 48.0,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeBgColor = backgroundColor ?? AppColors.accent;
    final activeFgColor = foregroundColor ?? (type == AppButtonType.primary ? Colors.white : AppColors.accent);

    Widget labelWidget = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: activeFgColor,
            ),
          )
        : AppText(
            label.toUpperCase(),
            color: activeFgColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 1.2,
          );

    Widget childWidget = icon != null && !isLoading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: activeFgColor),
              const SizedBox(width: 8),
              Flexible(child: labelWidget),
            ],
          )
        : labelWidget;

    Widget button;
    switch (type) {
      case AppButtonType.primary:
        button = ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: activeBgColor,
            foregroundColor: activeFgColor,
            disabledBackgroundColor: activeBgColor.withOpacity(0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: isLoading ? null : onPressed,
          child: childWidget,
        );
        break;
      case AppButtonType.outlined:
        button = OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: activeFgColor,
            side: BorderSide(color: activeBgColor, width: 1.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: isLoading ? null : onPressed,
          child: childWidget,
        );
        break;
      case AppButtonType.text:
        button = TextButton(
          style: TextButton.styleFrom(
            foregroundColor: activeFgColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onPressed: isLoading ? null : onPressed,
          child: childWidget,
        );
        break;
    }


    if (width != null) {
      return SizedBox(
        width: width,
        height: height,
        child: button,
      );
    }

    return SizedBox(
      height: height,
      child: button,
    );
  }
}
