import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/common/app_text.dart';

class WorkspaceHeader extends StatelessWidget implements PreferredSizeWidget {
  const WorkspaceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return AppBar(
      backgroundColor: AppColors.sectionBackground,
      elevation: 0,
      title: Row(
        children: [
          const Icon(Icons.favorite, color: AppColors.accentGold, size: 20),
          const SizedBox(width: 10),
          AppTitle(
            'Digital Wedding Invitation Workspace',
            color: isLight ? AppColors.primaryText : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: isLight ? AppColors.primaryText : Colors.white),
        onPressed: () => context.go('/'),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
