import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/common/app_text.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // Redirection delay
    Future.delayed(
      const Duration(milliseconds: 2600),
      () {
        if (mounted) {
          context.go('/');
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Branded Custom Painted Logo
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: AppDesign.glowShadow(AppColors.navyAccent),
                ),
                child: CustomPaint(
                  painter: GoldEmblemPainter(),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Branded Application name
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _textOpacity.value,
                  child: child,
                );
              },
              child: Column(
                children: [
                  const AppTitle(
                    'V I V A H',
                    color: AppColors.navyAccent,
                    fontSize: 28,
                    letterSpacing: 8.0,
                  ),
                  const SizedBox(height: 12),
                  AppText(
                    'DIGITAL INVITATION STUDIO',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navyAccent.withOpacity(0.5),
                    letterSpacing: 4.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom paint vector for the premium Gold logo
class GoldEmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.navyAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 4;

    // Draw inner circles
    canvas.drawCircle(center, radius - 8, paint);
    canvas.drawCircle(center, radius, paint);

    // Draw luxury floral star spokes
    const petCount = 8;
    for (int i = 0; i < petCount; i++) {
      final angle = (i * 2 * math.pi) / petCount;
      final petalCenter = center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      
      // Draw outer loops representing petals
      canvas.drawCircle(petalCenter, 10, paint);
      
      // Draw pointed vectors towards outside
      final outerTip = center + Offset(math.cos(angle) * (radius + 24), math.sin(angle) * (radius + 24));
      canvas.drawLine(petalCenter, outerTip, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
