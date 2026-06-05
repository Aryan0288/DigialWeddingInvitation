import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final bool isGlassmorphic;
  final bool showGlow;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.isGlassmorphic = false,
    this.showGlow = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    final defaultPadding = padding ?? const EdgeInsets.all(AppDesign.spaceMedium);
    final border = Border.all(
      color: borderColor ?? (isLight 
          ? AppColors.border 
          : (showGlow ? AppColors.navyAccent.withOpacity(0.3) : Colors.white.withOpacity(0.04))),
      width: showGlow ? 1.5 : 1.0,
    );

    final boxDecoration = BoxDecoration(
      color: isGlassmorphic 
          ? (isLight ? Colors.white.withOpacity(0.65) : const Color(0xFF0F1626).withOpacity(0.5)) 
          : (isLight ? AppColors.surface : AppColors.navySurface.withOpacity(0.65)),
      borderRadius: AppDesign.borderMedium,
      border: border,
      boxShadow: showGlow 
          ? AppDesign.glowShadow(isLight ? AppColors.accentGold : AppColors.navyAccent) 
          : (isLight 
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : AppDesign.cardShadow),
    );

    Widget container = Container(
      width: width,
      height: height,
      padding: defaultPadding,
      decoration: boxDecoration,
      child: child,
    );

    if (isGlassmorphic) {
      return ClipRRect(
        borderRadius: AppDesign.borderMedium,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: container,
        ),
      );
    }

    return container;
  }
}
