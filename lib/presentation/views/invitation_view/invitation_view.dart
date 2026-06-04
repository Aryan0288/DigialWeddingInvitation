import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/templates_widgets.dart';
import '../../widgets/common/app_text.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_text_field.dart';
import '../../../core/theme/app_theme.dart';
import '../../viewmodels/invitation_viewmodel.dart';
import '../../viewmodels/rsvp_viewmodel.dart';

class InvitationDetailView extends ConsumerStatefulWidget {
  final String invitationId;

  const InvitationDetailView({super.key, required this.invitationId});

  @override
  ConsumerState<InvitationDetailView> createState() => _InvitationDetailViewState();
}

class _InvitationDetailViewState extends ConsumerState<InvitationDetailView> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _showRSVPBottomSheet(String id) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.navySurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return GuestRSVPBottomSheet(invitationId: id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(invitationViewModelProvider(widget.invitationId));

    ref.listen(invitationViewModelProvider(widget.invitationId), (previous, next) {
      if (previous?.isLoading == true && next.isLoading == false) {
        _fadeController.forward();
      }
    });

    if (detailState.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.navyBackground,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.navyAccent,
          ),
        ),
      );
    }

    final invitation = detailState.invitation;

    if (invitation == null) {
      return Scaffold(
        backgroundColor: AppColors.navyBackground,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.navyAccent, size: 64),
                const SizedBox(height: 16),
                const AppTitle(
                  'Invitation Not Found',
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 8),
                const AppBody(
                  'The invitation link is invalid or has been deleted.',
                  color: Colors.white54,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Back to Home',
                  onPressed: () => context.go('/'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 768;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final Widget card = AspectRatio(
      aspectRatio: 9 / 16,
      child: Container(
        decoration: BoxDecoration(
          color: isLight ? Colors.white : const Color(0xFF1E2638),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isLight ? Colors.black.withOpacity(0.08) : Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 360,
            height: 640,
            child: InvitationTemplateFactory.getTemplate(
              templateId: invitation.selectedTemplateId,
              invitation: invitation,
              isPreview: false,
              availableTemplates: detailState.availableTemplates,
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.navyBackground,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.navySurface,
              AppColors.navyBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: FadeTransition(
              opacity: _fadeInAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: TextButton.icon(
                        onPressed: () => context.go('/'),
                        icon: const Icon(Icons.arrow_back, color: AppColors.navyAccent, size: 16),
                        label: const AppText('Design Invitation', color: AppColors.navyAccent, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (isDesktop)
                      SizedBox(height: 600, child: card)
                    else
                      card,

                    const SizedBox(height: 32),

                    Container(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: _buildCountdownCard(detailState.timeLeft),
                    ),

                    const SizedBox(height: 32),

                    AppButton(
                      label: 'RSVP Now',
                      onPressed: () => _showRSVPBottomSheet(invitation.id),
                      width: 250,
                      height: 56,
                    ),
                    const SizedBox(height: 16),
                    const AppBody(
                      'Please respond before the wedding celebrations',
                      color: Colors.white38,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownCard(Duration timeLeft) {
    final days = timeLeft.inDays;
    final hours = timeLeft.inHours % 24;
    final minutes = timeLeft.inMinutes % 60;
    final seconds = timeLeft.inSeconds % 60;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      borderColor: AppColors.navyAccent.withOpacity(0.2),
      child: Column(
        children: [
          const AppText(
            'COUNTDOWN TO THE BIG DAY',
            color: AppColors.navyAccent,
            fontSize: 11,
            letterSpacing: 3.0,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeItem(days.toString().padLeft(2, '0'), 'DAYS'),
              _buildDivider(),
              _buildTimeItem(hours.toString().padLeft(2, '0'), 'HOURS'),
              _buildDivider(),
              _buildTimeItem(minutes.toString().padLeft(2, '0'), 'MINS'),
              _buildDivider(),
              _buildTimeItem(seconds.toString().padLeft(2, '0'), 'SECS'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeItem(String value, String label) {
    return Column(
      children: [
        AppText(
          value,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.0,
          isSerif: true,
        ),
        const SizedBox(height: 6),
        AppText(
          label,
          fontSize: 9,
          color: AppColors.navyAccent.withOpacity(0.7),
          letterSpacing: 1.0,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppText(
        ':',
        fontSize: 20,
        color: AppColors.navyAccent.withOpacity(0.5),
        fontWeight: FontWeight.w300,
        isSerif: true,
      ),
    );
  }
}

class GuestRSVPBottomSheet extends ConsumerStatefulWidget {
  final String invitationId;
  const GuestRSVPBottomSheet({super.key, required this.invitationId});

  @override
  ConsumerState<GuestRSVPBottomSheet> createState() => _GuestRSVPBottomSheetState();
}

class _GuestRSVPBottomSheetState extends ConsumerState<GuestRSVPBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final rsvpState = ref.watch(guestRsvpViewModelProvider(widget.invitationId));

    if (rsvpState.isSubmitted) {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.navySurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(24, 32, 24, 32 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle, 
                color: isLight ? AppColors.success.withOpacity(0.12) : const Color(0xFF1E3A2F),
              ),
              child: Icon(
                Icons.check_circle_outline_rounded, 
                color: isLight ? AppColors.success : Colors.greenAccent, 
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const AppTitle(
              'RSVP Confirmed!',
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 12),
            AppBody(
              rsvpState.isAttending
                  ? "We are delighted to have you join us. Your confirmation has been saved successfully!"
                  : "We are sorry you won't be able to make it. Thank you for letting us know!",
              color: Colors.white60,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Close',
              type: AppButtonType.outlined,
              width: double.infinity,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navySurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppTitle(
                  'RSVP Confirmation',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                IconButton(
                  icon: Icon(Icons.close, color: isLight ? AppColors.primaryText.withOpacity(0.54) : Colors.white54), 
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(color: isLight ? AppColors.border : Colors.white10),
            const SizedBox(height: 16),

            AppTextField(
              controller: _nameController,
              label: 'YOUR NAME',
              hintText: 'Enter your name',
              validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText(
                  'ATTENDING?', 
                  color: AppColors.navyAccent,
                  fontSize: 10,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                ),
                Row(
                  children: [
                    ChoiceChip(
                      label: AppText(
                        'Yes', 
                        color: rsvpState.isAttending ? Colors.white : (isLight ? AppColors.primaryText : Colors.white70),
                        preventTranslation: rsvpState.isAttending,
                      ),
                      selectedColor: AppColors.navyAccent,
                      backgroundColor: isLight ? const Color(0xFFF3F4F6) : Colors.white.withOpacity(0.05),
                      selected: rsvpState.isAttending,
                      onSelected: (_) => ref.read(guestRsvpViewModelProvider(widget.invitationId).notifier).setAttending(true),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: AppText(
                        'No', 
                        color: !rsvpState.isAttending ? Colors.white : (isLight ? AppColors.primaryText : Colors.white70),
                        preventTranslation: !rsvpState.isAttending,
                      ),
                      selectedColor: AppColors.navyAccent,
                      backgroundColor: isLight ? const Color(0xFFF3F4F6) : Colors.white.withOpacity(0.05),
                      selected: !rsvpState.isAttending,
                      onSelected: (_) => ref.read(guestRsvpViewModelProvider(widget.invitationId).notifier).setAttending(false),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (rsvpState.isAttending) ...[
              const AppText(
                'NUMBER OF GUESTS', 
                color: AppColors.navyAccent,
                fontSize: 10,
                letterSpacing: 2.0,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isLight ? const Color(0xFFF9FAFB) : Colors.white.withOpacity(0.02), 
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isLight ? AppColors.border : Colors.white.withOpacity(0.05)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: rsvpState.guestCount,
                    dropdownColor: AppColors.navySurface,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.navyAccent),
                    isExpanded: true,
                    style: TextStyle(color: isLight ? AppColors.primaryText : Colors.white, fontSize: 14),
                    items: [1, 2, 3, 4, 5].map((val) => DropdownMenuItem(value: val, child: AppText('$val Guest${val > 1 ? "s" : ""}', fontSize: 14))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(guestRsvpViewModelProvider(widget.invitationId).notifier).setGuestCount(val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const AppText(
                'MEAL PREFERENCE', 
                color: AppColors.navyAccent,
                fontSize: 10,
                letterSpacing: 2.0,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 8),
              Row(
                children: ['Standard', 'Vegetarian', 'Vegan'].map((pref) {
                  final isSel = rsvpState.mealPreference == pref;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: AppText(
                        pref, 
                        color: isSel ? Colors.white : (isLight ? AppColors.primaryText : Colors.white70),
                        preventTranslation: isSel,
                      ),
                      selectedColor: AppColors.navyAccent,
                      backgroundColor: isLight ? const Color(0xFFF3F4F6) : Colors.white.withOpacity(0.05),
                      selected: isSel,
                      onSelected: (_) => ref.read(guestRsvpViewModelProvider(widget.invitationId).notifier).setMealPreference(pref),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
            ],

            AppButton(
              label: 'Confirm RSVP',
              isLoading: rsvpState.isSaving,
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await ref.read(guestRsvpViewModelProvider(widget.invitationId).notifier).submitRsvp(_nameController.text.trim());
                }
              },
              width: double.infinity,
              height: 52,
            ),
          ],
        ),
      ),
    );
  }
}
