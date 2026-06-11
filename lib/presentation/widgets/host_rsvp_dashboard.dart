import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/rsvp_model.dart';
import '../../data/repositories/invitation_repository.dart';
import '../widgets/common/app_text.dart';
import '../widgets/common/app_loading.dart';
import '../../core/theme/app_theme.dart';

class HostRsvpDashboard extends ConsumerWidget {
  final String invitationId;

  const HostRsvpDashboard({super.key, required this.invitationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rsvpsAsync = ref.watch(rsvpsStreamProvider(invitationId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        _StepSectionHeader(
          stepNum: '05',
          title: 'RSVP Dashboard',
          subtitle:
              'Track guest confirmations in real-time from your shared link',
        ),
        const SizedBox(height: 20),

        rsvpsAsync.when(
          data: (rsvps) => _DashboardContent(rsvps: rsvps),
          loading: () =>
              const AppLoading(message: 'Connecting to live RSVP feed…'),
          error: (err, _) => _ErrorCard(message: err.toString()),
        ),
      ],
    );
  }
}

// ── Dashboard content ───────────────────────────────────────────────────────

class _DashboardContent extends StatelessWidget {
  final List<RsvpModel> rsvps;
  const _DashboardContent({required this.rsvps});

  @override
  Widget build(BuildContext context) {
    if (rsvps.isEmpty) return const _EmptyState();

    final attending = rsvps.where((r) => r.isAttending).toList();
    final declined = rsvps.length - attending.length;
    int totalGuests = 0, vegCount = 0, veganCount = 0, stdCount = 0;

    for (final r in attending) {
      totalGuests += r.guestsCount;
      switch (r.mealPreference.toLowerCase()) {
        case 'vegetarian':
          vegCount += r.guestsCount;
          break;
        case 'vegan':
          veganCount += r.guestsCount;
          break;
        default:
          stdCount += r.guestsCount;
      }
    }

    return Column(
      children: [
        // Metric cards
        LayoutBuilder(builder: (ctx, constraints) {
          final narrow = constraints.maxWidth < 540;
          final cards = [
            _MetricData(
              label: 'Attending',
              value: totalGuests.toString(),
              icon: Icons.people_rounded,
              color: AppColors.success,
            ),
            _MetricData(
              label: 'Declined',
              value: declined.toString(),
              icon: Icons.person_off_rounded,
              color: AppColors.error,
            ),
            _MetricData(
              label: 'Responses',
              value: rsvps.length.toString(),
              icon: Icons.assignment_turned_in_rounded,
              color: const Color(0xFF2563EB),
            ),
          ];

          if (narrow) {
            return Column(
              children: cards
                  .map((d) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _MetricCard(data: d),
                      ))
                  .toList(),
            );
          }
          final w = (constraints.maxWidth - 20) / 3;
          return Row(
            children: cards
                .asMap()
                .entries
                .map((e) => Row(children: [
                      SizedBox(width: w, child: _MetricCard(data: e.value)),
                      if (e.key < 2) const SizedBox(width: 10),
                    ]))
                .toList(),
          );
        }),

        const SizedBox(height: 16),

        // Meal breakdown
        if (totalGuests > 0) ...[
          _MealBreakdownCard(
            std: stdCount,
            veg: vegCount,
            vegan: veganCount,
            total: totalGuests,
          ),
          const SizedBox(height: 16),
        ],

        // Guest list
        _GuestListCard(rsvps: rsvps),
      ],
    );
  }
}

// ── Metric card ─────────────────────────────────────────────────────────────

class _MetricData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricData(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});
}

class _MetricCard extends StatelessWidget {
  final _MetricData data;
  const _MetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(data.icon, color: data.color, size: 18),
          ),
          const SizedBox(height: 10),
          AppText(
            data.value,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
          const SizedBox(height: 2),
          AppBody(data.label,
              fontSize: 11, color: AppColors.secondaryText),
        ],
      ),
    );
  }
}

// ── Meal breakdown card ─────────────────────────────────────────────────────

class _MealBreakdownCard extends StatelessWidget {
  final int std;
  final int veg;
  final int vegan;
  final int total;

  const _MealBreakdownCard(
      {required this.std,
      required this.veg,
      required this.vegan,
      required this.total});

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.restaurant_menu_outlined,
                    color: Colors.amber, size: 16),
              ),
              const SizedBox(width: 10),
              const AppText(
                'Meal Preferences',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _MealRow(
              label: 'Standard / Regular',
              count: std,
              total: total,
              color: Colors.amber),
          const SizedBox(height: 10),
          _MealRow(
              label: 'Vegetarian',
              count: veg,
              total: total,
              color: Colors.green),
          const SizedBox(height: 10),
          _MealRow(
              label: 'Vegan',
              count: vegan,
              total: total,
              color: Colors.teal),
        ],
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _MealRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? count / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppBody(label,
                color: AppColors.secondaryText, fontSize: 12),
            AppText(
              '$count  (${(pct * 100).toStringAsFixed(0)}%)',
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 5,
            backgroundColor: AppColors.border.withOpacity(0.5),
            color: color,
          ),
        ),
      ],
    );
  }
}

// ── Guest list card ─────────────────────────────────────────────────────────

class _GuestListCard extends StatelessWidget {
  final List<RsvpModel> rsvps;
  const _GuestListCard({required this.rsvps});

  // Allocate the formatter once instead of inside the (former) itemBuilder.
  static final DateFormat _timeFormat = DateFormat('MMM d, h:mm a');

  static String _initialsFor(String name) {
    if (name.isEmpty) return '?';
    return name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase())
        .join();
  }

  @override
  Widget build(BuildContext context) {
    // Build the rows once (this widget only rebuilds when the RSVP stream
    // emits, not per frame). Using a Column instead of a shrink-wrapped
    // ListView avoids the extra layout pass of a nested non-scrolling list.
    final Color dividerColor = AppColors.border.withOpacity(0.4);
    final List<Widget> guestRows = [];
    for (int i = 0; i < rsvps.length; i++) {
      if (i > 0) {
        guestRows.add(Divider(color: dividerColor, height: 1));
      }
      guestRows.add(_GuestRow(
        rsvp: rsvps[i],
        timeStr: _timeFormat.format(rsvps[i].timestamp),
        initials: _initialsFor(rsvps[i].guestName),
      ));
    }

    return Container(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.list_alt_rounded,
                      color: Color(0xFF2563EB), size: 16),
                ),
                const SizedBox(width: 10),
                const AppText(
                  'Guest Confirmations',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AppText(
                    '${rsvps.length} total',
                    fontSize: 10,
                    color: const Color(0xFF2563EB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.border.withOpacity(0.6), height: 1),
          ...guestRows,
        ],
      ),
    );
  }
}

// ── Single guest row (display fields precomputed by the parent) ─────────────

class _GuestRow extends StatelessWidget {
  final RsvpModel rsvp;
  final String timeStr;
  final String initials;

  const _GuestRow({
    required this.rsvp,
    required this.timeStr,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    final r = rsvp;
    final avatarColor = r.isAttending ? AppColors.success : AppColors.error;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Avatar with initials
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avatarColor.withOpacity(0.10),
              border: Border.all(
                color: avatarColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: AppText(
                initials,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: avatarColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Guest info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  r.guestName,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (r.isAttending) ...[
                      _Pill(
                        label:
                            '${r.guestsCount} Guest${r.guestsCount > 1 ? "s" : ""}',
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      _Pill(
                        label: r.mealPreference,
                        color: Colors.amber.shade700,
                      ),
                    ] else
                      _Pill(label: 'Declined', color: AppColors.error),
                  ],
                ),
              ],
            ),
          ),
          // Timestamp
          AppBody(
            timeStr,
            fontSize: 10,
            color: AppColors.mutedText,
          ),
        ],
      ),
    );
  }
}

// ── Small pill badge ────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2), width: 0.8),
      ),
      child: AppText(
        label,
        fontSize: 9,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_unread_outlined,
                size: 32, color: AppColors.mutedText),
          ),
          const SizedBox(height: 16),
          const AppTitle(
            'No RSVPs Yet',
            fontSize: 18,
            color: AppColors.primaryText,
          ),
          const SizedBox(height: 6),
          const AppBody(
            'Once you share the web link from Step 4,\nguest responses will appear here instantly.',
            color: AppColors.secondaryText,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Error card ──────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: AppBody(
              'Failed to load RSVPs: $message',
              color: AppColors.error,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared step section header ──────────────────────────────────────────────

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
