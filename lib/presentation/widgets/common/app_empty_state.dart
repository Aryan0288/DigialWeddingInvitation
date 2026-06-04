import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'app_text.dart';
import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Styled Icon with subtle gold background glow
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.navyAccent.withOpacity(0.06),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.navyAccent.withOpacity(0.15)),
              ),
              child: Icon(
                icon,
                color: AppColors.navyAccent,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            AppHeading(
              title,
              textAlign: TextAlign.center,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            AppBody(
              description,
              textAlign: TextAlign.center,
              color: Colors.white38,
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 28),
              AppButton(
                label: actionLabel!,
                onPressed: onActionPressed!,
                type: AppButtonType.outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
