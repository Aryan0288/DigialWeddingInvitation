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

  // Allocate the formatter once instead of on every rebuild.
  static final DateFormat _dateFormat = DateFormat('d MMM y');

  const LogisticsSection({
    super.key,
    required this.formKey,
    required this.venueNameController,
    required this.venueAddressController,
  });

  Future<void> _selectDate(
      BuildContext context, WidgetRef ref, DateTime initial) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.accent,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.primaryText,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ref.read(builderViewModelProvider.notifier).updateWeddingDate(picked);
    }
  }

  Future<void> _selectTime(
      BuildContext context, WidgetRef ref, String current) async {
    final parts = current.split(':');
    final hour = parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 18) : 18;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.accent,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.primaryText,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      ref
          .read(builderViewModelProvider.notifier)
          .updateWeddingTime(formatted);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weddingDate = ref.watch(
        builderViewModelProvider.select((s) => s.invitation.weddingDate));
    final weddingTime = ref.watch(
        builderViewModelProvider.select((s) => s.invitation.weddingTime));
    final dateDisplay = _dateFormat.format(weddingDate);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          _StepSectionHeader(
            stepNum: '03',
            title: 'Event Details',
            subtitle: 'Date, time & venue appear on every template',
          ),
          const SizedBox(height: 20),

          // ── WHEN card ───────────────────────────────────────────────────
          _EventDetailCard(
            icon: Icons.event_note_outlined,
            iconColor: const Color(0xFF7B61FF),
            title: 'When is the Wedding?',
            child: Row(
              children: [
                Expanded(
                  child: _PickerField(
                    label: 'DATE',
                    value: dateDisplay,
                    trailingIcon: Icons.calendar_month_outlined,
                    onTap: () =>
                        _selectDate(context, ref, weddingDate),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PickerField(
                    label: 'TIME',
                    value: weddingTime,
                    trailingIcon: Icons.access_time_outlined,
                    onTap: () =>
                        _selectTime(context, ref, weddingTime),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── WHERE card ──────────────────────────────────────────────────
          _EventDetailCard(
            icon: Icons.location_on_outlined,
            iconColor: const Color(0xFFE53935),
            title: 'Where is the Ceremony?',
            child: Column(
              children: [
                AppTextField(
                  controller: venueNameController,
                  label: 'VENUE / HALL NAME',
                  hintText: 'e.g. The Grand Palace Ballroom',
                  onChanged: (val) => ref
                      .read(builderViewModelProvider.notifier)
                      .updateVenueName(val),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Venue name is required'
                      : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: venueAddressController,
                  label: 'FULL ADDRESS / TOWN',
                  hintText: 'e.g. 14 Palace Road, New Delhi',
                  maxLines: 2,
                  onChanged: (val) => ref
                      .read(builderViewModelProvider.notifier)
                      .updateVenueAddress(val),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Venue address is required'
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Event detail grouped card ───────────────────────────────────────────────

class _EventDetailCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _EventDetailCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 10),
              AppText(
                title,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── Tappable display field for date/time pickers ────────────────────────────

class _PickerField extends StatelessWidget {
  final String label;
  final String value;
  final IconData trailingIcon;
  final VoidCallback onTap;

  const _PickerField({
    required this.label,
    required this.value,
    required this.trailingIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: AppDesign.borderSmall,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: AppDesign.borderSmall,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AppText(
                    value,
                    color: AppColors.primaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(trailingIcon, color: AppColors.accent, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Shared step header ──────────────────────────────────────────────────────

class _StepSectionHeader extends StatelessWidget {
  final String stepNum;
  final String title;
  final String subtitle;

  const _StepSectionHeader({
    required this.stepNum,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'STEP $stepNum',
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        AppTitle(
          title,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
        const SizedBox(height: 4),
        AppBody(subtitle, color: AppColors.secondaryText, fontSize: 11),
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 1.5,
          decoration: BoxDecoration(
            color: AppColors.accentGold.withOpacity(0.55),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}
