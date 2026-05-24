import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/rsvp_model.dart';
import '../../data/repositories/invitation_repository.dart';

class HostRsvpDashboard extends ConsumerWidget {
  final String invitationId;

  const HostRsvpDashboard({super.key, required this.invitationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rsvpsAsync = ref.watch(rsvpsStreamProvider(invitationId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 5: Host RSVP Dashboard',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Serif',
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Track guest confirmations, headcounts, and meal preferences in real-time. This page listens directly to updates from your public link.',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 24),
        
        rsvpsAsync.when(
          data: (rsvps) => _buildDashboardContent(context, rsvps),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            ),
          ),
          error: (err, stack) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to load live RSVPs: $err',
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
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
    if (rsvps.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2638),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD4AF37).withOpacity(0.05),
              ),
              child: const Icon(
                Icons.mark_email_unread_outlined,
                color: Color(0xFFD4AF37),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No RSVPs Received Yet',
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Once you share the link in Step 4, guest submissions will appear here instantly!',
              style: TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
                  _buildMetricCard('Total Attending', totalHeadcount.toString(), Icons.people_rounded, const Color(0xFF2ECC71)),
                  const SizedBox(height: 12),
                  _buildMetricCard('Declined RSVPs', declinedRsvps.toString(), Icons.person_off_rounded, Colors.redAccent),
                  const SizedBox(height: 12),
                  _buildMetricCard('Total Responses', totalRsvpCount.toString(), Icons.assignment_turned_in_rounded, const Color(0xFFD4AF37)),
                ],
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _buildMetricCard('Total Attending', totalHeadcount.toString(), Icons.people_rounded, const Color(0xFF2ECC71)),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildMetricCard('Declined RSVPs', declinedRsvps.toString(), Icons.person_off_rounded, Colors.redAccent),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildMetricCard('Total Responses', totalRsvpCount.toString(), Icons.assignment_turned_in_rounded, const Color(0xFFD4AF37)),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 20),

        // Meal Preferences Breakdown Card
        if (totalHeadcount > 0) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2638),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.02)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MEAL PREFERENCE DISTRIBUTION',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                _buildMealProgressRow('Standard / Regular', standardCount, totalHeadcount, Colors.amber),
                const SizedBox(height: 12),
                _buildMealProgressRow('Vegetarian', vegCount, totalHeadcount, Colors.green),
                const SizedBox(height: 12),
                _buildMealProgressRow('Vegan', veganCount, totalHeadcount, Colors.teal),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Guest List Datatable
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1E2638),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.02)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Text(
                  'RECENT GUEST CONFIRMATIONS',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const Divider(color: Colors.white10, height: 1),
              
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rsvps.length,
                separatorBuilder: (context, idx) => const Divider(color: Colors.white10, height: 1),
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
                            ? const Color(0xFF2ECC71).withOpacity(0.1) 
                            : Colors.redAccent.withOpacity(0.1),
                      ),
                      child: Icon(
                        r.isAttending ? Icons.check_circle_outline : Icons.highlight_off,
                        color: r.isAttending ? const Color(0xFF2ECC71) : Colors.redAccent,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      r.guestName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      r.isAttending 
                          ? '${r.guestsCount} Guest${r.guestsCount > 1 ? "s" : ""} • ${r.mealPreference}'
                          : 'Declined Invitation',
                      style: TextStyle(
                        color: r.isAttending ? Colors.white70 : Colors.white30,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Text(
                      timeStr,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
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

  Widget _buildMetricCard(String label, String value, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2638),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
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
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealProgressRow(String label, int count, int total, Color color) {
    final double pct = total > 0 ? (count / total) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(
              '$count (${(pct * 100).toStringAsFixed(0)}%)',
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: Colors.white.withOpacity(0.04),
            color: color,
          ),
        ),
      ],
    );
  }
}
