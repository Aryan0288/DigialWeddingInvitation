import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/rsvp_model.dart';
import '../../data/repositories/invitation_repository.dart';
import '../widgets/common/app_text.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/app_empty_state.dart';
import '../widgets/common/app_loading.dart';
import '../../../core/theme/app_theme.dart';

class HostRsvpDashboard extends ConsumerWidget {
  final String invitationId;

  const HostRsvpDashboard({super.key, required this.invitationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rsvpsAsync = ref.watch(rsvpsStreamProvider(invitationId));
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTitle(
          'Step 5: Host RSVP Dashboard',
          color: isLight ? AppColors.primaryText : Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w400,
        ),
        const SizedBox(height: 8),
        AppBody(
          'Track guest confirmations, headcounts, and meal preferences in real-time. This page listens directly to updates from your public link.',
          color: isLight ? AppColors.secondaryText : Colors.white54,
          fontSize: 12,
        ),
        const SizedBox(height: 24),
        
        rsvpsAsync.when(
          data: (rsvps) => _buildDashboardContent(context, rsvps),
          loading: () => const AppLoading(message: 'Connecting to live RSVP feed...'),
          error: (err, stack) => AppCard(
            padding: const EdgeInsets.all(16),
            borderColor: AppColors.error.withOpacity(0.3),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.error),
                const SizedBox(width: 12),
                Expanded(
                  child: AppBody(
                    'Failed to load live RSVPs: $err',
                    color: AppColors.error,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardContent(BuildContext context, List<RsvpModel> rsvps) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    if (rsvps.isEmpty) {
      return const AppEmptyState(
        icon: Icons.mark_email_unread_outlined,
        title: 'No RSVPs Received Yet',
        description: 'Once you share the link in Step 4, guest submissions will appear here instantly!',
      );
    }

    // Summary calculations
    final totalRsvpCount = rsvps.length;
    final attendingList = rsvps.where((r) => r.isAttending).toList();
    final attendingRsvps = attendingList.length;
    final declinedRsvps = totalRsvpCount - attendingRsvps;

    // Total headcount including accompanying guests
    int totalHeadcount = 0;
    int vegCount = 0;
    int veganCount = 0;
    int standardCount = 0;

    for (var r in attendingList) {
      totalHeadcount += r.guestsCount;
      if (r.mealPreference.toLowerCase() == 'vegetarian') {
        vegCount += r.guestsCount;
      } else if (r.mealPreference.toLowerCase() == 'vegan') {
        veganCount += r.guestsCount;
      } else {
        standardCount += r.guestsCount;
      }
    }

    return Column(
      children: [
        // Metric Cards Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final double cardWidth = (constraints.maxWidth - 24) / 3;
            final isNarrow = constraints.maxWidth < 600;

            if (isNarrow) {
              return Column(
                children: [
                  _buildMetricCard(context, 'Total Attending', totalHeadcount.toString(), Icons.people_rounded, AppColors.success),
                  const SizedBox(height: 12),
                  _buildMetricCard(context, 'Declined RSVPs', declinedRsvps.toString(), Icons.person_off_rounded, AppColors.error),
                  const SizedBox(height: 12),
                  _buildMetricCard(context, 'Total Responses', totalRsvpCount.toString(), Icons.assignment_turned_in_rounded, isLight ? const Color(0xFF2563EB) : AppColors.navyAccent),
                ],
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _buildMetricCard(context, 'Total Attending', totalHeadcount.toString(), Icons.people_rounded, AppColors.success),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildMetricCard(context, 'Declined RSVPs', declinedRsvps.toString(), Icons.person_off_rounded, AppColors.error),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildMetricCard(context, 'Total Responses', totalRsvpCount.toString(), Icons.assignment_turned_in_rounded, isLight ? const Color(0xFF2563EB) : AppColors.navyAccent),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 20),

        // Meal Preferences Breakdown Card
        if (totalHeadcount > 0) ...[
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'MEAL PREFERENCE DISTRIBUTION',
                  color: isLight ? const Color(0xFF2563EB) : AppColors.navyAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
                const SizedBox(height: 16),
                _buildMealProgressRow('Standard / Regular', standardCount, totalHeadcount, Colors.amber, isLight),
                const SizedBox(height: 12),
                _buildMealProgressRow('Vegetarian', vegCount, totalHeadcount, Colors.green, isLight),
                const SizedBox(height: 12),
                _buildMealProgressRow('Vegan', veganCount, totalHeadcount, Colors.teal, isLight),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Guest List Datatable
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: AppText(
                  'RECENT GUEST CONFIRMATIONS',
                  color: isLight ? const Color(0xFF2563EB) : AppColors.navyAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Divider(color: isLight ? AppColors.border : Colors.white10, height: 1),
              
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rsvps.length,
                separatorBuilder: (context, idx) => Divider(color: isLight ? AppColors.border : Colors.white10, height: 1),
                itemBuilder: (context, index) {
                  final r = rsvps[index];
                  final timeStr = DateFormat('MMM d, h:mm a').format(r.timestamp);

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: r.isAttending 
                            ? AppColors.success.withOpacity(0.1) 
                            : AppColors.error.withOpacity(0.1),
                      ),
                      child: Icon(
                        r.isAttending ? Icons.check_circle_outline : Icons.highlight_off,
                        color: r.isAttending ? AppColors.success : AppColors.error,
                        size: 20,
                      ),
                    ),
                    title: AppText(
                      r.guestName,
                      color: isLight ? AppColors.primaryText : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    subtitle: AppBody(
                      r.isAttending 
                          ? '${r.guestsCount} Guest${r.guestsCount > 1 ? "s" : ""} • ${r.mealPreference}'
                          : 'Declined Invitation',
                      color: r.isAttending 
                          ? (isLight ? AppColors.secondaryText : Colors.white70) 
                          : (isLight ? AppColors.secondaryText.withOpacity(0.5) : Colors.white30),
                      fontSize: 12,
                    ),
                    trailing: AppBody(
                      timeStr,
                      color: isLight ? AppColors.secondaryText.withOpacity(0.6) : Colors.white38,
                      fontSize: 11,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String label, String value, IconData icon, Color accentColor) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  value,
                  color: isLight ? AppColors.primaryText : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                const SizedBox(height: 2),
                AppBody(
                  label,
                  color: isLight ? AppColors.secondaryText : Colors.white38,
                  fontSize: 11,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealProgressRow(String label, int count, int total, Color color, bool isLight) {
    final double pct = total > 0 ? (count / total) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppBody(label, color: isLight ? AppColors.secondaryText : Colors.white70, fontSize: 12),
            AppText(
              '$count (${(pct * 100).toStringAsFixed(0)}%)',
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: isLight ? const Color(0xFFE5E7EB) : Colors.white.withOpacity(0.04),
            color: color,
          ),
        ),
      ],
    );
  }
}
