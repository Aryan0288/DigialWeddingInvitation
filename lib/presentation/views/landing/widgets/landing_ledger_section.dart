import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/invitation_model.dart';
import '../../../../data/repositories/invitation_repository.dart';
import '../../../widgets/common/app_text.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/scroll_entrance.dart';

final ledgerActiveInvitationsProvider = Provider.autoDispose<List<InvitationModel>>((ref) {
  final savedInvitations = ref.watch(draftsProvider);
  final publishedKeys = ref.watch(mockPublishedKeysProvider);
  final activeIds = ref.watch(activeInvitationIdsProvider);

  return savedInvitations.where((inv) {
    final isPublished = publishedKeys.contains(inv.id);
    final isActivated = activeIds.contains(inv.id);
    return isPublished || isActivated;
  }).toList();
});

class LandingLedgerSection extends ConsumerWidget {
  const LandingLedgerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeInvitations = ref.watch(ledgerActiveInvitationsProvider);
    final publishedKeys = ref.watch(mockPublishedKeysProvider);

    if (activeInvitations.isEmpty) {
      return const SizedBox.shrink();
    }

    final isLight = Theme.of(context).brightness == Brightness.light;

    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: ScrollEntrance(
        type: ScrollEntranceType.slideUp,
        delayIndex: 2,
        triggerOnScroll: false,
        child: AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          borderColor: const Color(0x1F1E293B), // 12% opacity navyAccent/slate
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.bookmark_added_outlined, color: AppColors.navyAccent, size: 20),
                  SizedBox(width: 10),
                  AppText(
                    'YOUR ACTIVE INVITATIONS',
                    color: AppColors.navyAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeInvitations.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final inv = activeInvitations[index];
                  final isLive = publishedKeys.contains(inv.id);

                  return InvitationLedgerItemCard(
                    invitation: inv,
                    isLive: isLive,
                    index: index,
                    isLight: isLight,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InvitationLedgerItemCard extends StatelessWidget {
  final InvitationModel invitation;
  final bool isLive;
  final int index;
  final bool isLight;

  const InvitationLedgerItemCard({
    super.key,
    required this.invitation,
    required this.isLive,
    required this.index,
    required this.isLight,
  });

  // DateFormat cached statically
  static final DateFormat _dateFormat = DateFormat('MMMM d, y');

  @override
  Widget build(BuildContext context) {
    final names = invitation.brideName.isEmpty && invitation.groomName.isEmpty
        ? "Draft Invitation (Untitled)"
        : "${invitation.brideName} & ${invitation.groomName}";
    
    final dateStr = _dateFormat.format(invitation.weddingDate);
    final venueNameText = invitation.venueName.isEmpty ? 'Not set' : invitation.venueName;

    // Use constant opacity colors
    final Color cardBgColor = isLight ? AppColors.sectionBackground : const Color(0x05FFFFFF);
    final Color cardBorderColor = isLight ? AppColors.border : const Color(0x0AFFFFFF);
    final Color badgeBgColor = isLive
        ? (isLight ? const Color(0xFFD1FAE5) : const Color(0xFF1E3A2F))
        : (isLight ? const Color(0xFFF3F4F6) : const Color(0xFF2A2A2A));
    final Color badgeTextColor = isLive
        ? (isLight ? const Color(0xFF065F46) : Colors.greenAccent)
        : (isLight ? const Color(0xFF374151) : Colors.white60);

    return ScrollEntrance(
      type: ScrollEntranceType.fadeIn,
      delayIndex: index,
      triggerOnScroll: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: AppDesign.borderMedium,
          border: Border.all(color: cardBorderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: AppText(
                                names,
                                color: isLight ? AppColors.primaryText : Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                isSerif: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: badgeBgColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: AppText(
                                isLive ? 'LIVE' : 'DRAFT',
                                color: badgeTextColor,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AppBody(
                    'Wedding Date: $dateStr • Venue: $venueNameText',
                    color: isLight ? AppColors.secondaryText : Colors.white54,
                    fontSize: 11,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AppButton(
              label: 'Track RSVPs',
              type: AppButtonType.outlined,
              icon: Icons.analytics_outlined,
              onPressed: () => context.go('/builder?id=${invitation.id}&step=4'),
              height: 30,
            ),
            const SizedBox(width: 8),
            AppButton(
              label: 'Edit Card',
              type: AppButtonType.outlined,
              icon: Icons.edit_outlined,
              onPressed: () => context.go('/builder?id=${invitation.id}'),
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
