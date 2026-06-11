import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../viewmodels/builder_viewmodel.dart';

class WorkspaceStepper extends ConsumerWidget {
  final int currentStep;

  const WorkspaceStepper({super.key, required this.currentStep});

  static const List<String> _labels = [
    'Theme',
    'Couple',
    'Event',
    'Share',
    'RSVP',
  ];

  static const List<IconData> _icons = [
    Icons.palette_outlined,
    Icons.people_alt_outlined,
    Icons.event_note_outlined,
    Icons.send_outlined,
    Icons.bar_chart_rounded,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final circleSize = screenWidth < 400 ? 28.0 : 34.0;
    final iconSize = screenWidth < 400 ? 13.0 : 15.0;
    final labelSize = screenWidth < 400 ? 8.0 : 9.0;

    return Row(
      children: List.generate(5, (index) {
        final isActive = index == currentStep;
        final isPassed = index < currentStep;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      ref.read(builderViewModelProvider.notifier).setStep(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Circle indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? AppColors.accent
                              : isPassed
                                  ? AppColors.success.withOpacity(0.10)
                                  : const Color(0xFFF2EDE4),
                          border: Border.all(
                            color: isActive
                                ? AppColors.accent
                                : isPassed
                                    ? AppColors.success
                                    : AppColors.border,
                            width: isActive ? 0 : 1.5,
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.accent.withOpacity(0.32),
                                    blurRadius: 14,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: isPassed
                              ? Icon(Icons.check_rounded,
                                  color: AppColors.success, size: iconSize + 1)
                              : Icon(
                                  _icons[index],
                                  color: isActive
                                      ? Colors.white
                                      : AppColors.mutedText,
                                  size: iconSize,
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Label
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: labelSize,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isActive
                              ? AppColors.accent
                              : isPassed
                                  ? AppColors.success
                                  : AppColors.mutedText,
                          letterSpacing: 0.5,
                        ),
                        child: Text(_labels[index].toUpperCase()),
                      ),
                    ],
                  ),
                ),
              ),
              // Connector line
              if (index < 4)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: screenWidth < 400 ? 12 : 18,
                  height: 1.5,
                  margin: EdgeInsets.only(bottom: circleSize / 2 + labelSize + 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                    color: index < currentStep
                        ? AppColors.success
                        : AppColors.border.withOpacity(0.5),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
