import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/common/app_text.dart';
import '../../../widgets/common/app_button.dart';

class LandingHeader extends StatelessWidget {
  const LandingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
        color: isLight ? AppColors.sectionBackground : AppColors.navySurface.withOpacity(0.3),
        border: Border(bottom: BorderSide(color: isLight ? AppColors.border : Colors.white.withOpacity(0.03))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.navyAccent, width: 1),
                ),
                child: const Icon(Icons.favorite, color: AppColors.navyAccent, size: 14),
              ),
              const SizedBox(width: 10),
              const AppText(
                'VIVAH',
                color: AppColors.navyAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                isSerif: true,
              ),
            ],
          ),
          AppButton(
            label: 'Start Creating',
            onPressed: () => context.go('/builder'),
            height: 38,
          ),
        ],
      ),
    );
  }
}
