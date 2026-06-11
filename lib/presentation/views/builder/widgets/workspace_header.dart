import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/common/app_text.dart';
import '../../../viewmodels/builder_viewmodel.dart';

class WorkspaceHeader extends ConsumerWidget implements PreferredSizeWidget {
  const WorkspaceHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaving =
        ref.watch(builderViewModelProvider.select((s) => s.isSaving));

    return AppBar(
      backgroundColor: AppColors.sectionBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: const Border(
        bottom: BorderSide(color: AppColors.border),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded,
            color: AppColors.primaryText, size: 20),
        onPressed: () => context.go('/'),
        tooltip: 'Back to Home',
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Brand mark
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.navyAccent, width: 1.0),
              color: AppColors.navyAccent.withOpacity(0.06),
            ),
            child: const Icon(Icons.favorite,
                color: AppColors.navyAccent, size: 13),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppText(
                'VIVAH STUDIO',
                color: AppColors.navyAccent,
                fontSize: 19,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                isSerif: true,
              ),
              AppBody(
                'Invitation Builder',
                color: AppColors.mutedText,
                fontSize: 9,
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Draft status chip
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 13),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
          decoration: BoxDecoration(
            color: isSaving
                ? AppColors.accentGold.withOpacity(0.07)
                : AppColors.success.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSaving
                  ? AppColors.accentGold.withOpacity(0.28)
                  : AppColors.success.withOpacity(0.22),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSaving ? AppColors.accentGold : AppColors.success,
                ),
              ),
              const SizedBox(width: 6),
              AppText(
                isSaving ? 'Saving…' : 'Draft Saved',
                color: isSaving ? AppColors.accentGold : AppColors.success,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
