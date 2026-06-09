import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/templates_widgets.dart';

class LandingBackground extends StatelessWidget {
  const LandingBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return RepaintBoundary(
      child: Stack(
        children: [
          // Elegant background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isLight
                      ? [
                          AppColors.sectionBackground,
                          AppColors.background,
                          AppColors.sectionBackground,
                        ]
                      : [
                          AppColors.navySurface,
                          AppColors.navyBackground,
                          const Color(0xFF02040A),
                        ],
                ),
              ),
            ),
          ),

          // Glowing radial lights (heavy blur isolated here)
          Positioned(
            top: size.height * 0.1,
            left: size.width * 0.1,
            child: Container(
              key: const ValueKey('glow_light_1'),
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.navyAccent.withOpacity(0.015),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navyAccent.withOpacity(0.06),
                    blurRadius: 150,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          // Rotating/static background decoration mandalas
          Positioned(
            top: -120,
            right: -120,
            child: SizedBox(
              width: 450,
              height: 450,
              child: CustomPaint(
                painter: MandalaPainter(color: AppColors.navyAccent.withOpacity(0.035)),
              ),
            ),
          ),
          Positioned(
            bottom: -180,
            left: -180,
            child: SizedBox(
              width: 500,
              height: 500,
              child: CustomPaint(
                painter: MandalaPainter(color: AppColors.navyAccent.withOpacity(0.025)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
