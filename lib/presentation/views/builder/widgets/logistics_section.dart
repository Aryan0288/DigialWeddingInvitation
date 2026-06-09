import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/common/app_text.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../viewmodels/builder_viewmodel.dart';

class LogisticsSection extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController venueNameController;
  final TextEditingController venueAddressController;

  const LogisticsSection({
    super.key,
    required this.formKey,
    required this.venueNameController,
    required this.venueAddressController,
  });

  // Pick Date Helper
  Future<void> _selectDate(BuildContext context, WidgetRef ref, DateTime initialDate) async {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isLight 
                ? const ColorScheme.light(
                    primary: AppColors.accent,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: AppColors.primaryText,
                  )
                : const ColorScheme.dark(
                    primary: AppColors.accent,
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E2638),
                    onSurface: Colors.white,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      ref.read(builderViewModelProvider.notifier).updateWeddingDate(picked);
    }
  }

  // Pick Time Helper
  Future<void> _selectTime(BuildContext context, WidgetRef ref, String currentTime) async {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final parts = currentTime.split(':');
    final int hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 18 : 18;
    final int minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isLight 
                ? const ColorScheme.light(
                    primary: AppColors.accent,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: AppColors.primaryText,
                  )
                : const ColorScheme.dark(
                    primary: AppColors.accent,
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E2638),
                    onSurface: Colors.white,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final String formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      ref.read(builderViewModelProvider.notifier).updateWeddingTime(formattedTime);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(builderViewModelProvider);
    final dateDisplay = DateFormat('MMMM d, y').format(state.invitation.weddingDate);
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTitle(
            "Step 3: Event Logistics",
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: isLight ? AppColors.primaryText : Colors.white,
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppLabel("WEDDING DATE"),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context, ref, state.invitation.weddingDate),
                      borderRadius: AppDesign.borderSmall,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isLight ? const Color(0xFFF9FAFB) : const Color(0xFF1E2638),
                          borderRadius: AppDesign.borderSmall,
                          border: Border.all(color: isLight ? AppColors.border : Colors.white10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              dateDisplay,
                              color: isLight ? AppColors.primaryText : Colors.white,
                              fontSize: 14,
                            ),
                            Icon(Icons.calendar_month, color: AppColors.accent, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppLabel("WEDDING TIME"),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectTime(context, ref, state.invitation.weddingTime),
                      borderRadius: AppDesign.borderSmall,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isLight ? const Color(0xFFF9FAFB) : const Color(0xFF1E2638),
                          borderRadius: AppDesign.borderSmall,
                          border: Border.all(color: isLight ? AppColors.border : Colors.white10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              state.invitation.weddingTime,
                              color: isLight ? AppColors.primaryText : Colors.white,
                              fontSize: 14,
                            ),
                            Icon(Icons.access_time, color: AppColors.accent, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          AppTextField(
            controller: venueNameController,
            label: "VENUE HALL NAME",
            hintText: "e.g. Royal Ballroom, Grand Palace Resort",
            onChanged: (val) {
              ref.read(builderViewModelProvider.notifier).updateVenueName(val);
            },
            validator: (value) => value == null || value.trim().isEmpty ? 'Venue name is required' : null,
          ),
          const SizedBox(height: 20),

          AppTextField(
            controller: venueAddressController,
            label: "VENUE ADDRESS / TOWN",
            hintText: "e.g. Plot 14, Ring Road, New Delhi",
            maxLines: 2,
            onChanged: (val) {
              ref.read(builderViewModelProvider.notifier).updateVenueAddress(val);
            },
            validator: (value) => value == null || value.trim().isEmpty ? 'Venue address is required' : null,
          ),
        ],
      ),
    );
  }
}
