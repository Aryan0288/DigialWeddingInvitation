import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';
import '../../widgets/templates_widgets.dart';
import '../../viewmodels/builder_viewmodel.dart';
import '../../widgets/host_rsvp_dashboard.dart';
import '../../widgets/common/app_text.dart';
import '../../widgets/common/app_button.dart';
import '../../../core/theme/app_theme.dart';

import 'widgets/workspace_header.dart';
import 'widgets/workspace_stepper.dart';
import 'widgets/template_selector_section.dart';
import 'widgets/couple_details_section.dart';
import 'widgets/logistics_section.dart';
import 'widgets/review_export_section.dart';

class InvitationBuilderView extends ConsumerStatefulWidget {
  final String? editingId;
  final int? startStep;
  final int? preselectedTemplateId;

  const InvitationBuilderView({
    super.key,
    this.editingId,
    this.startStep,
    this.preselectedTemplateId,
  });

  @override
  ConsumerState<InvitationBuilderView> createState() =>
      _InvitationBuilderViewState();
}

class _InvitationBuilderViewState extends ConsumerState<InvitationBuilderView>
    with SingleTickerProviderStateMixin {
  final ScreenshotController _screenshotController = ScreenshotController();
  final _formKeyStep2 = GlobalKey<FormState>();
  final _formKeyStep3 = GlobalKey<FormState>();

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

    Future.microtask(() async {
      await ref
          .read(builderViewModelProvider.notifier)
          .loadInvitation(widget.editingId);
      final invitation = ref.read(builderViewModelProvider).invitation;

      _brideController.text = invitation.brideName;
      _groomController.text = invitation.groomName;
      _venueNameController.text = invitation.venueName;
      _venueAddressController.text = invitation.venueAddress;
      _messageController.text = invitation.personalMessage;

      if (widget.startStep != null) {
        ref
            .read(builderViewModelProvider.notifier)
            .setStep(widget.startStep!);
      }
      if (widget.preselectedTemplateId != null) {
        ref
            .read(builderViewModelProvider.notifier)
            .selectTemplate(widget.preselectedTemplateId!);
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

  @override
  Widget build(BuildContext context) {
    final currentStep =
        ref.watch(builderViewModelProvider.select((s) => s.currentStep));
    final invitationId =
        ref.watch(builderViewModelProvider.select((s) => s.invitation.id));
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const WorkspaceHeader(),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left: Elevated white form panel
            SizedBox(
              width: 440,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.sectionBackground,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 32,
                      offset: Offset(4, 0),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top accent strip
                    Container(
                      height: 2,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accentGold,
                            Color(0xFFF1C232),
                            AppColors.accentGold,
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: WorkspaceStepper(currentStep: currentStep),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child:
                            _buildActiveFormStep(currentStep, invitationId),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                      decoration: BoxDecoration(
                        color: AppColors.sectionBackground,
                        border: Border(
                          top: BorderSide(
                              color: AppColors.border.withOpacity(0.6)),
                        ),
                      ),
                      child: _buildNavigationButtons(currentStep),
                    ),
                  ],
                ),
              ),
            ),

            // Right: Dark studio preview stage
            Expanded(
              child: _StudioStage(screenshotController: _screenshotController),
            ),
          ],
        ),
      );
    }

    // ── MOBILE LAYOUT ──────────────────────────────────────────────────────
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.sectionBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.navyAccent, width: 1),
              ),
              child: const Icon(Icons.favorite,
                  color: AppColors.navyAccent, size: 11),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppText(
                  'VIVAH STUDIO',
                  color: AppColors.navyAccent,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  isSerif: true,
                ),
                AppBody(
                  'Invitation Builder',
                  color: AppColors.secondaryText,
                  fontSize: 9,
                ),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.primaryText, size: 20),
          onPressed: () => context.go('/'),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1 + 42),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(height: 1, color: AppColors.border),
              TabBar(
                controller: _mobileTabController,
                indicatorColor: AppColors.accent,
                indicatorWeight: 2,
                labelColor: AppColors.accent,
                unselectedLabelColor: AppColors.secondaryText,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontSize: 13),
                tabs: const [
                  Tab(text: 'Design'),
                  Tab(text: 'Preview'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _mobileTabController,
        children: [
          // Tab 1: Form
          Container(
            color: AppColors.sectionBackground,
            child: Column(
              children: [
                Container(
                  height: 2,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentGold,
                        Color(0xFFF1C232),
                        AppColors.accentGold,
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: WorkspaceStepper(currentStep: currentStep),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child:
                        _buildActiveFormStep(currentStep, invitationId),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  decoration: BoxDecoration(
                    color: AppColors.sectionBackground,
                    border: Border(
                      top: BorderSide(
                          color: AppColors.border.withOpacity(0.5)),
                    ),
                  ),
                  child: _buildNavigationButtons(currentStep),
                ),
              ],
            ),
          ),

          // Tab 2: Dark studio preview
          Container(
            color: AppColors.navyPrimary,
            child: Column(
              children: [
                const SizedBox(height: 20),
                const _LivePill(),
                const SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: _LivePreviewPanel(
                        screenshotController: _screenshotController),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '1080 × 1920 px  •  HD Export Ready',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.18),
                    fontSize: 9,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFormStep(int currentStep, String invitationId) {
    switch (currentStep) {
      case 0:
        return const TemplateSelectorSection();
      case 1:
        return CoupleDetailsSection(
          formKey: _formKeyStep2,
          brideController: _brideController,
          groomController: _groomController,
          messageController: _messageController,
        );
      case 2:
        return LogisticsSection(
          formKey: _formKeyStep3,
          venueNameController: _venueNameController,
          venueAddressController: _venueAddressController,
        );
      case 3:
        return ReviewExportSection(
          screenshotController: _screenshotController,
        );
      case 4:
        return HostRsvpDashboard(invitationId: invitationId);
      default:
        return const TemplateSelectorSection();
    }
  }

  Widget _buildNavigationButtons(int currentStep) {
    final showBack = currentStep > 0;
    final isLast = currentStep == 4;

    return Row(
      children: [
        if (showBack) ...[
          Expanded(
            child: AppButton(
              label: 'Back',
              type: AppButtonType.outlined,
              onPressed: () =>
                  ref.read(builderViewModelProvider.notifier).previousStep(),
            ),
          ),
          const SizedBox(width: 12),
        ],
        if (!isLast)
          Expanded(
            child: AppButton(
              label: 'Continue',
              icon: Icons.arrow_forward_rounded,
              onPressed: () {
                if (currentStep == 1 &&
                    !_formKeyStep2.currentState!.validate()) {
                  return;
                }
                if (currentStep == 2 &&
                    !_formKeyStep3.currentState!.validate()) {
                  return;
                }
                ref.read(builderViewModelProvider.notifier).nextStep();
              },
            ),
          )
        else
          const Expanded(child: SizedBox.shrink()),
      ],
    );
  }
}

// ── Studio Stage (dark warm background + centered preview) ─────────────────

class _StudioStage extends ConsumerWidget {
  final ScreenshotController screenshotController;
  const _StudioStage({required this.screenshotController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templateId = ref.watch(
        builderViewModelProvider.select((s) => s.invitation.selectedTemplateId));
    final templates = ref
        .watch(builderViewModelProvider.select((s) => s.availableTemplates));

    String templateName = 'Classic Mandala';
    if (templates.isNotEmpty) {
      try {
        final match = templates.firstWhere((t) => t.id == templateId);
        templateName = match.title;
      } catch (_) {}
    }

    return Container(
      color: AppColors.navyPrimary,
      child: Column(
        children: [
          const SizedBox(height: 28),
          const _LivePill(),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 56),
              child: _LivePreviewPanel(
                  screenshotController: screenshotController),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            templateName,
            style: TextStyle(
              color: Colors.white.withOpacity(0.50),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            '1080 × 1920 px  •  HD Export Ready',
            style: TextStyle(
              color: Colors.white.withOpacity(0.18),
              fontSize: 9,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Pulsing live indicator pill ────────────────────────────────────────────

class _LivePill extends StatefulWidget {
  const _LivePill();

  @override
  State<_LivePill> createState() => _LivePillState();
}

class _LivePillState extends State<_LivePill>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _dotOpacity;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _dotOpacity = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _dotOpacity,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.55),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'LIVE PREVIEW',
            style: TextStyle(
              color: Colors.white.withOpacity(0.38),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Live preview panel (card + glow shadow) ────────────────────────────────

class _LivePreviewPanel extends ConsumerWidget {
  final ScreenshotController screenshotController;
  const _LivePreviewPanel({required this.screenshotController});

  // Static — preview chrome never changes between rebuilds.
  static const BorderRadius _previewRadius =
      BorderRadius.all(Radius.circular(16));
  static const BoxDecoration _previewDecoration = BoxDecoration(
    borderRadius: _previewRadius,
    boxShadow: [
      BoxShadow(
        color: Color(0x40000000),
        blurRadius: 24,
        offset: Offset(0, 12),
      ),
    ],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read the debounced invitation so rapid typing coalesces into a single
    // rebuild of the heavy template tree (~300ms after typing stops).
    // availableTemplates is watched granularly so unrelated state
    // (currentStep, loading flags) never triggers a preview rebuild.
    final invitation = ref.watch(debouncedInvitationProvider);
    final availableTemplates = ref
        .watch(builderViewModelProvider.select((s) => s.availableTemplates));

    return Center(
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: Container(
          decoration: _previewDecoration,
          child: ClipRRect(
            borderRadius: _previewRadius,
            child: RepaintBoundary(
              child: Screenshot(
                controller: screenshotController,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: 360,
                    height: 640,
                    child: InvitationTemplateFactory.getTemplate(
                      templateId: invitation.selectedTemplateId,
                      invitation: invitation,
                      isPreview: true,
                      availableTemplates: availableTemplates,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
