import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';
import 'package:intl/intl.dart';
import '../../../data/models/invitation_model.dart';
import '../../widgets/templates_widgets.dart';
import '../../viewmodels/builder_viewmodel.dart';
import '../../widgets/host_rsvp_dashboard.dart';

class InvitationBuilderView extends ConsumerStatefulWidget {
  final String? editingId;
  final int? startStep;

  const InvitationBuilderView({super.key, this.editingId, this.startStep});

  @override
  ConsumerState<InvitationBuilderView> createState() => _InvitationBuilderViewState();
}

class _InvitationBuilderViewState extends ConsumerState<InvitationBuilderView> with SingleTickerProviderStateMixin {
  final ScreenshotController _screenshotController = ScreenshotController();
  final _formKeyStep2 = GlobalKey<FormState>();
  final _formKeyStep3 = GlobalKey<FormState>();

  // Text Controllers
  late TextEditingController _brideController;
  late TextEditingController _groomController;
  late TextEditingController _venueNameController;
  late TextEditingController _venueAddressController;
  late TextEditingController _messageController;

  late TabController _mobileTabController;

  @override
  void initState() {
    super.initState();
    _mobileTabController = TabController(length: 2, vsync: this);

    _brideController = TextEditingController();
    _groomController = TextEditingController();
    _venueNameController = TextEditingController();
    _venueAddressController = TextEditingController();
    _messageController = TextEditingController();

    // Trigger load invitation
    Future.microtask(() async {
      await ref.read(builderViewModelProvider.notifier).loadInvitation(widget.editingId);
      final invitation = ref.read(builderViewModelProvider).invitation;
      
      // Seed text controllers
      _brideController.text = invitation.brideName;
      _groomController.text = invitation.groomName;
      _venueNameController.text = invitation.venueName;
      _venueAddressController.text = invitation.venueAddress;
      _messageController.text = invitation.personalMessage;

      // Jump to startStep directly if supplied (e.g. step 5 from home page)
      if (widget.startStep != null) {
        ref.read(builderViewModelProvider.notifier).setStep(widget.startStep!);
      }
    });
  }

  @override
  void dispose() {
    _brideController.dispose();
    _groomController.dispose();
    _venueNameController.dispose();
    _venueAddressController.dispose();
    _messageController.dispose();
    _mobileTabController.dispose();
    super.dispose();
  }

  // Pick Date Helper
  Future<void> _selectDate(BuildContext context, WidgetRef ref, DateTime initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4AF37),
              onPrimary: Colors.black,
              surface: Color(0xFF0F1626),
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
    final parts = currentTime.split(':');
    final int hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 18 : 18;
    final int minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4AF37),
              onPrimary: Colors.black,
              surface: Color(0xFF0F1626),
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
  Widget build(BuildContext context) {
    final state = ref.watch(builderViewModelProvider);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;

    final Widget previewCard = Center(
      child: AspectRatio(
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
          child: Screenshot(
            controller: _screenshotController,
            child: InvitationTemplateFactory.getTemplate(
              templateId: state.invitation.selectedTemplateId,
              invitation: state.invitation,
              isPreview: true,
              availableTemplates: state.availableTemplates,
            ),
          ),
        ),
      ),
    );

    if (isDesktop) {
      // DESKTOP LAYOUT (Side-by-side panels)
      return Scaffold(
        backgroundColor: const Color(0xFF070B19),
        appBar: _buildAppBar(),
        body: Row(
          children: [
            // Left Panel (Wizard Input Forms)
            Expanded(
              flex: 4,
              child: Container(
                color: const Color(0xFF0F1626),
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    _buildStepIndicator(state.currentStep),
                    const SizedBox(height: 32),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildActiveFormStep(state),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildNavigationButtons(state),
                  ],
                ),
              ),
            ),
            
            // Right Panel (Live Invitation Preview Workspace)
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF070B19),
                      const Color(0xFF070B19).withOpacity(0.9),
                    ],
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 64),
                child: previewCard,
              ),
            ),
          ],
        ),
      );
    } else {
      // MOBILE LAYOUT (Tabs interface)
      return Scaffold(
        backgroundColor: const Color(0xFF070B19),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F1626),
          title: const Text('Invitation Workspace', style: TextStyle(color: Color(0xFFD4AF37), fontFamily: 'Serif')),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/'),
          ),
          bottom: TabBar(
            controller: _mobileTabController,
            indicatorColor: const Color(0xFFD4AF37),
            labelColor: const Color(0xFFD4AF37),
            unselectedLabelColor: Colors.white60,
            tabs: const [
              Tab(icon: Icon(Icons.edit_note), text: "Edit Details"),
              Tab(icon: Icon(Icons.preview_outlined), text: "Live Preview"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _mobileTabController,
          children: [
            // Tab 1: Wizard inputs
            Container(
              color: const Color(0xFF0F1626),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildStepIndicator(state.currentStep),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildActiveFormStep(state),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNavigationButtons(state),
                ],
              ),
            ),

            // Tab 2: Live preview
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                children: [
                  Expanded(child: previewCard),
                  const SizedBox(height: 16),
                  // Short notice
                  const Text(
                    "Switch back to 'Edit Details' to update information",
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0F1626),
      elevation: 0,
      title: const Row(
        children: [
          Icon(Icons.favorite, color: Color(0xFFD4AF37), size: 20),
          SizedBox(width: 10),
          Text(
            'Digital Wedding Invitation Workspace',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontFamily: 'Serif',
              fontSize: 18,
            ),
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.go('/'),
      ),
    );
  }

  Widget _buildStepIndicator(int currentStep) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        final isActive = index == currentStep;
        final isPassed = index < currentStep;
        
        return Row(
          children: [
            GestureDetector(
              onTap: () {
                ref.read(builderViewModelProvider.notifier).setStep(index);
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive 
                      ? const Color(0xFFD4AF37) 
                      : (isPassed ? const Color(0xFF1E3A2F) : Colors.white.withOpacity(0.04)),
                  border: Border.all(
                    color: isActive ? const Color(0xFFD4AF37) : Colors.white24,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: isPassed 
                      ? const Icon(Icons.check, size: 16, color: Colors.green) 
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.black : Colors.white54,
                          ),
                        ),
                ),
              ),
            ),
            if (index < 4)
              Container(
                width: 30,
                height: 1,
                color: index < currentStep ? const Color(0xFF1E3A2F) : Colors.white12,
              ),
          ],
        );
      }),
    );
  }

  Widget _buildActiveFormStep(BuilderState state) {
    switch (state.currentStep) {
      case 0:
        return _buildTemplateSelector(state);
      case 1:
        return _buildCoupleDetailsForm();
      case 2:
        return _buildScheduleVenueForm(state);
      case 3:
        return _buildExportPanel(state);
      case 4:
        return HostRsvpDashboard(invitationId: state.invitation.id);
      default:
        return _buildTemplateSelector(state);
    }
  }

  // STEP 1: Select design templates
  Widget _buildTemplateSelector(BuilderState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 1: Select Design Template',
          style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'Serif'),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose the premium theme style for your digital wedding card. You can toggle this dynamically at any time.',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 24),
        
        if (state.availableTemplates.isEmpty) ...[
          _buildTemplateItem(
            id: 1,
            title: "Classic Mandala (Gold & Red)",
            desc: "Rich dark royal red with golden concentric patterns and luxury Sanskrit headers.",
            selectedId: state.invitation.selectedTemplateId,
            accentColor: const Color(0xFF5B0000),
          ),
          const SizedBox(height: 16),
          _buildTemplateItem(
            id: 2,
            title: "Royal Peacock (Maroon & Teal)",
            desc: "Elegant deep maroon backdrop complemented by teal peacock elements and gold frames.",
            selectedId: state.invitation.selectedTemplateId,
            accentColor: const Color(0xFF380208),
          ),
          const SizedBox(height: 16),
          _buildTemplateItem(
            id: 3,
            title: "Rose Gold (Minimalist Floral)",
            desc: "Beautiful blush rose gold shimmers bordered with detailed thin floral leafy branches.",
            selectedId: state.invitation.selectedTemplateId,
            accentColor: const Color(0xFFEAD1D5),
            textColor: Colors.black87,
          ),
        ] else
          ...state.availableTemplates.map((t) {
            final color = HexColor.fromHex(t.primaryColorHex);
            final textColor = t.id == 3 ? Colors.black87 : Colors.white;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildTemplateItem(
                id: t.id,
                title: t.title,
                desc: t.description,
                selectedId: state.invitation.selectedTemplateId,
                accentColor: color,
                textColor: textColor,
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildTemplateItem({
    required int id,
    required String title,
    required String desc,
    required int selectedId,
    required Color accentColor,
    Color textColor = Colors.white,
  }) {
    final isSelected = id == selectedId;

    return InkWell(
      onTap: () {
        ref.read(builderViewModelProvider.notifier).selectTemplate(id);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2638),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.04),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Dummy Mini Card Preview Circle
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white30, width: 0.5),
              ),
              child: Center(
                child: Text(
                  'T$id',
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFFD4AF37) : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: const TextStyle(fontSize: 11, color: Colors.white54, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFFD4AF37) : Colors.white30,
            ),
          ],
        ),
      ),
    );
  }

  // STEP 2: Couple details forms
  Widget _buildCoupleDetailsForm() {
    return Form(
      key: _formKeyStep2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Step 2: Couple Details",
            style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'Serif'),
          ),
          const SizedBox(height: 24),
          
          _buildFormLabel("BRIDE'S NAME"),
          TextFormField(
            controller: _brideController,
            style: const TextStyle(color: Colors.white),
            decoration: _buildInputDecoration("Enter Bride's Name"),
            onChanged: (val) {
              ref.read(builderViewModelProvider.notifier).updateBrideName(val);
            },
            validator: (value) => value == null || value.trim().isEmpty ? 'Bride name is required' : null,
          ),
          const SizedBox(height: 20),

          _buildFormLabel("GROOM'S NAME"),
          TextFormField(
            controller: _groomController,
            style: const TextStyle(color: Colors.white),
            decoration: _buildInputDecoration("Enter Groom's Name"),
            onChanged: (val) {
              ref.read(builderViewModelProvider.notifier).updateGroomName(val);
            },
            validator: (value) => value == null || value.trim().isEmpty ? 'Groom name is required' : null,
          ),
          const SizedBox(height: 20),

          _buildFormLabel("PERSONAL WELCOME MESSAGE (OPTIONAL)"),
          TextFormField(
            controller: _messageController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: _buildInputDecoration("e.g. Together with our families, we invite you..."),
            onChanged: (val) {
              ref.read(builderViewModelProvider.notifier).updatePersonalMessage(val);
            },
          ),
        ],
      ),
    );
  }

  // STEP 3: Event schedules forms
  Widget _buildScheduleVenueForm(BuilderState state) {
    final dateDisplay = DateFormat('MMMM d, y').format(state.invitation.weddingDate);

    return Form(
      key: _formKeyStep3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Step 3: Event Logistics",
            style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'Serif'),
          ),
          const SizedBox(height: 24),

          // Date & Time pickers Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormLabel("WEDDING DATE"),
                    InkWell(
                      onTap: () => _selectDate(context, ref, state.invitation.weddingDate),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2638),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(dateDisplay, style: const TextStyle(color: Colors.white, fontSize: 14)),
                            const Icon(Icons.calendar_month, color: Color(0xFFD4AF37), size: 18),
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
                    _buildFormLabel("WEDDING TIME"),
                    InkWell(
                      onTap: () => _selectTime(context, ref, state.invitation.weddingTime),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2638),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(state.invitation.weddingTime, style: const TextStyle(color: Colors.white, fontSize: 14)),
                            const Icon(Icons.access_time, color: Color(0xFFD4AF37), size: 18),
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

          _buildFormLabel("VENUE HALL NAME"),
          TextFormField(
            controller: _venueNameController,
            style: const TextStyle(color: Colors.white),
            decoration: _buildInputDecoration("e.g. Royal Ballroom, Grand Palace Resort"),
            onChanged: (val) {
              ref.read(builderViewModelProvider.notifier).updateVenueName(val);
            },
            validator: (value) => value == null || value.trim().isEmpty ? 'Venue name is required' : null,
          ),
          const SizedBox(height: 20),

          _buildFormLabel("VENUE ADDRESS / TOWN"),
          TextFormField(
            controller: _venueAddressController,
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            decoration: _buildInputDecoration("e.g. Plot 14, Ring Road, New Delhi"),
            onChanged: (val) {
              ref.read(builderViewModelProvider.notifier).updateVenueAddress(val);
            },
            validator: (value) => value == null || value.trim().isEmpty ? 'Venue address is required' : null,
          ),
        ],
      ),
    );
  }

  // STEP 4: Complete and export
  Widget _buildExportPanel(BuilderState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Step 4: Review & Export",
          style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'Serif'),
        ),
        const SizedBox(height: 8),
        const Text(
          "Everything is set! You can now download your high-resolution card as an image or generate a unique digital link to share with your guests.",
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 32),

        // Action A: PNG Image Export
        _buildActionCard(
          icon: Icons.image_outlined,
          title: "Download PNG Invitation",
          desc: "Saves a high-definition 1080x1920 portrait format PNG to your downloads.",
          actionLabel: "Export PNG",
          onAction: () async {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Capturing high-resolution image...'), duration: Duration(seconds: 1)),
            );
            final success = await ref.read(builderViewModelProvider.notifier).downloadPNG(_screenshotController);
            if (success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PNG successfully saved to downloads!'), backgroundColor: Colors.green),
              );
            }
          },
        ),

        const SizedBox(height: 24),

        // Action B: Shareable URL
        _buildActionCard(
          icon: Icons.link_outlined,
          title: "Generate Web invitation Link",
          desc: "Creates a unique dynamic link that guests can visit to view the card reactively.",
          actionLabel: "Generate URL",
          isLoading: state.isSaving,
          onAction: () async {
            // Get local host location URL safely
            final String hostUrl = Uri.base.origin + Uri.base.path;
            await ref.read(builderViewModelProvider.notifier).saveAndGenerateLink(hostUrl);
          },
        ),

        if (state.generatedUrl != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "SHAREABLE URL GENERATED",
                  style: TextStyle(color: Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        state.generatedUrl!,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16, color: Color(0xFFD4AF37)),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: state.generatedUrl!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied shareable link to clipboard!'), duration: Duration(seconds: 1)),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String desc,
    required String actionLabel,
    required VoidCallback onAction,
    bool isLoading = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2638),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFD4AF37), size: 22),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(fontSize: 11, color: Colors.white54, height: 1.4)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isLoading ? null : onAction,
              child: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.black87))
                  : Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // Small helpers
  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFD4AF37),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
      filled: true,
      fillColor: Colors.white.withOpacity(0.03),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.0),
      ),
    );
  }

  Widget _buildNavigationButtons(BuilderState state) {
    final showBack = state.currentStep > 0;
    final isLast = state.currentStep == 4;

    return Row(
      children: [
        if (showBack) ...[
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD4AF37)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ref.read(builderViewModelProvider.notifier).previousStep();
                },
                child: const Text('Back', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        if (!isLast)
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (state.currentStep == 1 && !_formKeyStep2.currentState!.validate()) {
                    return;
                  }
                  if (state.currentStep == 2 && !_formKeyStep3.currentState!.validate()) {
                    return;
                  }
                  ref.read(builderViewModelProvider.notifier).nextStep();
                },
                child: const Text('Next', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          )
        else
          const Expanded(child: SizedBox.shrink()),
      ],
    );
  }
}
