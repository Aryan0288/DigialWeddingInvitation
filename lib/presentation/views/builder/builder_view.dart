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

      // Pre-select template if query parameter is provided
      if (widget.preselectedTemplateId != null) {
        ref.read(builderViewModelProvider.notifier).selectTemplate(widget.preselectedTemplateId!);
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
    final currentStep = ref.watch(builderViewModelProvider.select((s) => s.currentStep));
    final invitationId = ref.watch(builderViewModelProvider.select((s) => s.invitation.id));
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final Widget previewCard = _LivePreviewPanel(
      screenshotController: _screenshotController,
    );

    if (isDesktop) {
      // DESKTOP LAYOUT (Side-by-side panels)
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const WorkspaceHeader(),
        body: Row(
          children: [
            // Left Panel (Wizard Input Forms)
            Expanded(
              flex: 4,
              child: Container(
                color: AppColors.sectionBackground,
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    WorkspaceStepper(currentStep: currentStep),
                    const SizedBox(height: 32),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildActiveFormStep(currentStep, invitationId),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildNavigationButtons(currentStep),
                  ],
                ),
              ),
            ),

            // Right Panel (Live Studio Preview Frame)
            Expanded(
              flex: 5,
              child: Container(
                color: isLight ? const Color(0xFFFCFAF7) : const Color(0xFF23201D),
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.brush_outlined, color: AppColors.accent, size: 14),
                        SizedBox(width: 8),
                        AppText(
                          'LIVE INVITATION PREVIEW',
                          color: AppColors.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: previewCard,
                    ),
                    const SizedBox(height: 16),
                    AppBody(
                      'Real-time WYSIWYG Rendering Engine',
                      color: isLight ? AppColors.secondaryText : Colors.white30,
                      fontSize: 10,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // MOBILE LAYOUT (TabBar Toggle tabs between form inputs & preview)
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.sectionBackground,
        title: Row(
          children: [
            const Icon(Icons.favorite, color: AppColors.accentGold, size: 20),
            const SizedBox(width: 10),
            AppTitle(
              'Digital Wedding Invitation Workspace',
              color: isLight ? AppColors.primaryText : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isLight ? AppColors.primaryText : Colors.white),
          onPressed: () => context.go('/'),
        ),
        bottom: TabBar(
          controller: _mobileTabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: isLight ? AppColors.secondaryText : Colors.white54,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Edit Details', icon: Icon(Icons.edit_note, size: 20)),
            Tab(text: 'Live Preview', icon: Icon(Icons.visibility, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _mobileTabController,
        children: [
          // Tab 1: Wizard Input Forms
          Container(
            color: AppColors.sectionBackground,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                WorkspaceStepper(currentStep: currentStep),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildActiveFormStep(currentStep, invitationId),
                  ),
                ),
                const SizedBox(height: 16),
                _buildNavigationButtons(currentStep),
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
                AppBody(
                  "Switch back to 'Edit Details' to update information",
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
              onPressed: () {
                ref.read(builderViewModelProvider.notifier).previousStep();
              },
            ),
          ),
          const SizedBox(width: 16),
        ],
        if (!isLast)
          Expanded(
            child: AppButton(
              label: 'Next',
              onPressed: () {
                if (currentStep == 1 && !_formKeyStep2.currentState!.validate()) {
                  return;
                }
                if (currentStep == 2 && !_formKeyStep3.currentState!.validate()) {
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

class _LivePreviewPanel extends ConsumerWidget {
  final ScreenshotController screenshotController;
  const _LivePreviewPanel({required this.screenshotController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(builderViewModelProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Center(
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: Container(
          decoration: BoxDecoration(
            color: isLight ? Colors.white : const Color(0xFF1E2638),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isLight ? const Color(0x1A2D2A26) : Colors.black.withOpacity(0.5),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: RepaintBoundary(
            child: Screenshot(
              controller: screenshotController,
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 360,
                  height: 640,
                  child: InvitationTemplateFactory.getTemplate(
                    templateId: state.invitation.selectedTemplateId,
                    invitation: state.invitation,
                    isPreview: true,
                    availableTemplates: state.availableTemplates,
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
