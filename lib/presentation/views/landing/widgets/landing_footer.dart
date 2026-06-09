import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/common/app_text.dart';

class LandingFooter extends StatelessWidget {
  const LandingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Column(
      children: [
        Divider(color: isLight ? AppColors.border : Colors.white10),
        const SizedBox(height: 24),
        AppBody(
          '© 2026 VIVAH Digital Wedding Invitation Workspace. Crafted with luxury design principles.',
          color: isLight ? AppColors.mutedText : Colors.white30,
          fontSize: 11,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
