import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../viewmodels/landing_viewmodel.dart';
import '../../../widgets/common/app_text.dart';
import '../../../widgets/common/app_section_title.dart';
import '../../../widgets/common/scroll_entrance.dart';

class ShowcaseTitleAndTabs extends ConsumerWidget {
  const ShowcaseTitleAndTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final landingState = ref.watch(landingViewModelProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: ScrollEntrance(
        type: ScrollEntranceType.slideUp,
        delayIndex: 1,
        triggerOnScroll: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const AppSectionTitle(
              title: 'Choose Your Wedding Design',
              subtitle: 'Explore Premium Themes',
            ),
            const SizedBox(height: 32),

            // Collection Categories Filter Tabs
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isLight
                    ? AppColors.inputFill
                    : AppColors.navySurface.withOpacity(0.6),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isLight
                      ? AppColors.border
                      : Colors.white.withOpacity(0.04),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Royal', 'Luxury', 'Floral', 'Modern'].map((
                    category,
                  ) {
                    final isSelected =
                        landingState.selectedCollection == category;
                    return GestureDetector(
                      onTap: () {
                        ref
                            .read(landingViewModelProvider.notifier)
                            .selectCollection(category);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.navyAccent
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: AppText(
                          category,
                          color: isSelected
                              ? Colors.white
                              : (isLight
                                    ? AppColors.secondaryText
                                    : Colors.white70),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}
