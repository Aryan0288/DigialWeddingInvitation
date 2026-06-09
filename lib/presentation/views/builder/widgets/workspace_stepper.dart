import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/common/app_text.dart';
import '../../../viewmodels/builder_viewmodel.dart';

class WorkspaceStepper extends ConsumerWidget {
  final int currentStep;

  const WorkspaceStepper({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepTitles = ['Theme', 'Couple', 'Logistics', 'Publish', 'RSVP'];
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isLight ? AppColors.sectionBackground : Colors.white.withOpacity(0.01),
        borderRadius: AppDesign.borderMedium,
        border: Border.all(color: isLight ? AppColors.border : Colors.white.withOpacity(0.02)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          final isActive = index == currentStep;
          final isPassed = index < currentStep;
          
          Color stepBgColor;
          Color stepBorderColor;
          Widget stepChild;

          if (isActive) {
            stepBgColor = AppColors.accent;
            stepBorderColor = AppColors.accent;
            stepChild = AppText(
              '${index + 1}',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            );
          } else if (isPassed) {
            stepBgColor = AppColors.success.withOpacity(0.12);
            stepBorderColor = AppColors.success;
            stepChild = const Icon(
              Icons.check,
              size: 14,
              color: Color(0xFF065F46),
            );
          } else {
            stepBgColor = isLight ? const Color(0xFFF3F4F6) : Colors.white.withOpacity(0.04);
            stepBorderColor = isLight ? const Color(0xFFE5E7EB) : Colors.white12;
            stepChild = AppText(
              '${index + 1}',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isLight ? AppColors.secondaryText : Colors.white54,
            );
          }

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ref.read(builderViewModelProvider.notifier).setStep(index);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: AppDesign.durationFast,
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: stepBgColor,
                            border: Border.all(
                              color: stepBorderColor,
                              width: 1.5,
                            ),
                            boxShadow: isActive ? AppDesign.glowShadow(AppColors.accent) : null,
                          ),
                          child: Center(child: stepChild),
                        ),
                        const SizedBox(height: 6),
                        AppText(
                          stepTitles[index],
                          fontSize: 9,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          color: isActive 
                              ? AppColors.accent 
                              : (isLight ? AppColors.secondaryText : Colors.white38),
                          letterSpacing: 0.5,
                        ),
                      ],
                    ),
                  ),
                ),
                if (index < 4)
                  Container(
                    width: 20,
                    height: 1.5,
                    color: index < currentStep 
                        ? AppColors.success 
                        : (isLight ? AppColors.border : Colors.white12),
                    margin: const EdgeInsets.only(bottom: 14),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
