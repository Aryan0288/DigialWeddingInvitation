import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'app_text.dart';

class AppSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final CrossAxisAlignment crossAxisAlignment;

  const AppSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (subtitle != null) ...[
          AppText(
            subtitle!.toUpperCase(),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.navyAccent,
            letterSpacing: 3.5,
          ),
          const SizedBox(height: 8),
        ],
        AppText(
          title,
          fontSize: 24,
          fontWeight: FontWeight.w300,
          color: Colors.white,
          isSerif: true,
        ),
        const SizedBox(height: 12),
        // Decorative Gold Line
        Container(
          width: 50,
          height: 1.5,
          color: AppColors.navyAccent,
        ),
      ],
    );
  }
}
