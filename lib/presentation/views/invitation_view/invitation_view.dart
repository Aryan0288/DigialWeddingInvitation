import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/invitation_model.dart';
import '../../../data/models/rsvp_model.dart';
import '../../../data/models/remote_template_model.dart';
import '../../../data/repositories/invitation_repository.dart';
import 'package:uuid/uuid.dart';
import '../../widgets/templates_widgets.dart';

class InvitationDetailView extends ConsumerStatefulWidget {
  final String invitationId;

  const InvitationDetailView({super.key, required this.invitationId});

  @override
  ConsumerState<InvitationDetailView> createState() => _InvitationDetailViewState();
}

class _InvitationDetailViewState extends ConsumerState<InvitationDetailView> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeInAnimation;
  late Timer _countdownTimer;
  Duration _timeLeft = const Duration();
  InvitationModel? _invitation;
  List<RemoteTemplateModel> _availableTemplates = [];
  bool _isLoading = true;

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

    _loadInvitation();
  }

  Future<void> _loadInvitation() async {
    final repo = ref.read(invitationRepositoryProvider);
    final data = await repo.getCloudInvitation(widget.invitationId);
    final templates = await repo.fetchRemoteTemplates();
    
    if (mounted) {
      setState(() {
        _invitation = data;
        _availableTemplates = templates;
        _isLoading = false;
      });

      if (data != null) {
        _fadeController.forward();
        _updateCountdown();
        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _updateCountdown();
        });
      }
    }
  }

  void _updateCountdown() {
    if (_invitation == null) return;
    final now = DateTime.now();
    final difference = _invitation!.weddingDate.difference(now);
    if (mounted) {
      setState(() {
        _timeLeft = difference.isNegative ? Duration.zero : difference;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    if (_invitation != null) {
      _countdownTimer.cancel();
    }
    super.dispose();
  }

  // Launch RSVP bottom sheet
  void _showRSVPBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F1626),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return GuestRSVPBottomSheet(invitationId: _invitation!.id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF070B19),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFD4AF37),
          ),
        ),
      );
    }

    if (_invitation == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF070B19),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFD4AF37), size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Invitation Not Found',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Serif'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'The invitation link is invalid or has been deleted.',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black87,
                  ),
                  onPressed: () => context.go('/'),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 768;

    final Widget card = AspectRatio(
      aspectRatio: 9 / 16,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: InvitationTemplateFactory.getTemplate(
          templateId: _invitation!.selectedTemplateId,
          invitation: _invitation!,
          isPreview: false,
          availableTemplates: _availableTemplates,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F1626),
              Color(0xFF070B19),
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
                    // Back button to home/builder (Only for desktop/debug)
                    Align(
                      alignment: Alignment.topLeft,
                      child: TextButton.icon(
                        onPressed: () => context.go('/'),
                        icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37), size: 16),
                        label: const Text('Design Invitation', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 13)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Centered Invitation Card
                    if (isDesktop)
                      SizedBox(height: 600, child: card)
                    else
                      card,

                    const SizedBox(height: 32),

                    // Countdown card
                    Container(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: _buildCountdownCard(),
                    ),

                    const SizedBox(height: 32),

                    // RSVP Call-To-Action Button
                    SizedBox(
                      height: 56,
                      width: 250,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: const Color(0xFFD4AF37).withOpacity(0.3),
                        ),
                        onPressed: _showRSVPBottomSheet,
                        child: const Text(
                          'RSVP Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Please respond before the wedding celebrations',
                      style: TextStyle(color: Colors.white38, fontSize: 11, fontStyle: FontStyle.italic),
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

  Widget _buildCountdownCard() {
    final days = _timeLeft.inDays;
    final hours = _timeLeft.inHours % 24;
    final minutes = _timeLeft.inMinutes % 60;
    final seconds = _timeLeft.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1626),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'COUNTDOWN TO THE BIG DAY',
            style: TextStyle(
              color: const Color(0xFFD4AF37).withOpacity(0.7),
              fontSize: 11,
              letterSpacing: 2.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
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
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.white38,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Text(
      ':',
      style: TextStyle(
        fontSize: 20,
        color: const Color(0xFFD4AF37).withOpacity(0.5),
        fontWeight: FontWeight.w300,
      ),
    );
  }
}

// RSVP bottom sheet for guests
class GuestRSVPBottomSheet extends ConsumerStatefulWidget {
  final String invitationId;
  const GuestRSVPBottomSheet({super.key, required this.invitationId});

  @override
  ConsumerState<GuestRSVPBottomSheet> createState() => _GuestRSVPBottomSheetState();
}

class _GuestRSVPBottomSheetState extends ConsumerState<GuestRSVPBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _guestCount = 1;
  String _mealPreference = 'Standard';
  bool _isAttending = true;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    if (_isSubmitted) {
      return Padding(
        padding: EdgeInsets.fromLTRB(24, 32, 24, 32 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1E3A2F)),
              child: const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 24),
            const Text(
              'RSVP Confirmed!',
              style: TextStyle(fontFamily: 'Serif', fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _isAttending
                  ? "We are delighted to have you join us. Your confirmation has been saved successfully!"
                  : "We are sorry you won't be able to make it. Thank you for letting us know!",
              style: const TextStyle(fontSize: 14, color: Colors.white60, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD4AF37)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Close', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
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
                const Text(
                  'RSVP Confirmation',
                  style: TextStyle(fontFamily: 'Serif', fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(color: Colors.white10),
            const SizedBox(height: 16),

            const Text('YOUR NAME', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter your name',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Colors.white.withOpacity(0.04),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ATTENDING?', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Yes'),
                      selected: _isAttending,
                      onSelected: (_) => setState(() => _isAttending = true),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('No'),
                      selected: !_isAttending,
                      onSelected: (_) => setState(() => _isAttending = false),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_isAttending) ...[
              const Text('NUMBER OF GUESTS', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(12)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _guestCount,
                    dropdownColor: const Color(0xFF0F1626),
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD4AF37)),
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    items: [1, 2, 3, 4, 5].map((val) => DropdownMenuItem(value: val, child: Text('$val Guest${val > 1 ? "s" : ""}'))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _guestCount = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text('MEAL PREFERENCE', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: ['Standard', 'Vegetarian', 'Vegan'].map((pref) {
                  final isSel = _mealPreference == pref;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(pref),
                      selected: isSel,
                      onSelected: (_) => setState(() => _mealPreference = pref),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
            ],

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final rsvp = RsvpModel(
                      id: const Uuid().v4(),
                      guestName: _nameController.text.trim(),
                      guestsCount: _isAttending ? _guestCount : 0,
                      mealPreference: _isAttending ? _mealPreference : 'Standard',
                      isAttending: _isAttending,
                      timestamp: DateTime.now(),
                    );
                    
                    await ref.read(invitationRepositoryProvider).submitRsvp(widget.invitationId, rsvp);
                    
                    if (mounted) {
                      setState(() => _isSubmitted = true);
                    }
                  }
                },
                child: const Text('Confirm RSVP', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
