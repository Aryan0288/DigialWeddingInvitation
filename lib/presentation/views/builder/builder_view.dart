import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../widgets/templates_widgets.dart';
import '../../viewmodels/builder_viewmodel.dart';
import '../../widgets/host_rsvp_dashboard.dart';
import '../../../data/repositories/invitation_repository.dart';
import '../../widgets/common/app_text.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_text_field.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/export_service.dart' as platform_export;

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
              primary: AppColors.navyAccent,
              onPrimary: Colors.black,
              surface: AppColors.navySurface,
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
              primary: AppColors.navyAccent,
              onPrimary: Colors.black,
              surface: AppColors.navySurface,
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
    final isLight = Theme.of(context).brightness == Brightness.light;

    final Widget previewCard = Center(
      child: AspectRatio(
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
          child: Screenshot(
            controller: _screenshotController,
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
    );

    if (isDesktop) {
      // DESKTOP LAYOUT (Side-by-side panels)
      return Scaffold(
        backgroundColor: AppColors.navyBackground,
        appBar: _buildAppBar(),
        body: Row(
          children: [
            // Left Panel (Wizard Input Forms)
            Expanded(
              flex: 4,
              child: Container(
                color: AppColors.navySurface,
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

            // Right Panel (Live Studio Preview Frame)
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.9,
                    colors: isLight
                        ? [
                            const Color(0xFFFDFBF7),
                            AppColors.navyBackground,
                          ]
                        : [
                            const Color(0xFF141D32),
                            AppColors.navyBackground,
                          ],
                  ),
                ),
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.video_settings, color: AppColors.navyAccent, size: 14),
                        SizedBox(width: 8),
                        AppText(
                          'STUDIO PREVIEW PORT',
                          color: AppColors.navyAccent,
                          fontSize: 9,
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
                    const AppBody(
                      'Real-time WYSIWYG Rendering Engine',
                      color: Colors.white30,
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
      backgroundColor: AppColors.navyBackground,
      appBar: AppBar(
        backgroundColor: AppColors.navySurface,
        title: const AppText(
          'Vivah Studio Workspace',
          color: AppColors.navyAccent,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          isSerif: true,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isLight ? AppColors.primaryText : Colors.white),
          onPressed: () => context.go('/'),
        ),
        bottom: TabBar(
          controller: _mobileTabController,
          indicatorColor: AppColors.navyAccent,
          labelColor: AppColors.navyAccent,
          unselectedLabelColor: Colors.white54,
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
            color: AppColors.navySurface,
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
                const AppBody(
                  "Switch back to 'Edit Details' to update information",
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return AppBar(
      backgroundColor: AppColors.navySurface,
      elevation: 0,
      title: Row(
        children: [
          const Icon(Icons.favorite, color: AppColors.accentGold, size: 20),
          const SizedBox(width: 10),
          AppText(
            'Digital Wedding Invitation Workspace',
            color: isLight ? AppColors.primaryText : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            isSerif: true,
          ),
        ],
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: isLight ? AppColors.primaryText : Colors.white),
        onPressed: () => context.go('/'),
      ),
    );
  }

  Widget _buildStepIndicator(int currentStep) {
    final stepTitles = ['Theme', 'Couple', 'Logistics', 'Publish', 'RSVP'];
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isLight ? AppColors.navySurface : Colors.white.withOpacity(0.01),
        borderRadius: AppDesign.borderMedium,
        border: Border.all(color: isLight ? AppColors.border : Colors.white.withOpacity(0.02)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          final isActive = index == currentStep;
          final isPassed = index < currentStep;
          
          Color stepBgColor;
          Color stepBorderColor;
          Widget stepChild;

          if (isActive) {
            stepBgColor = isLight ? const Color(0xFF2563EB) : AppColors.navyAccent;
            stepBorderColor = isLight ? const Color(0xFF2563EB) : AppColors.navyAccent;
            stepChild = AppText(
              '${index + 1}',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            );
          } else if (isPassed) {
            stepBgColor = isLight ? AppColors.success.withOpacity(0.12) : const Color(0xFF1E3A2F);
            stepBorderColor = isLight ? AppColors.success : Colors.green.withOpacity(0.5);
            stepChild = Icon(
              Icons.check,
              size: 14,
              color: isLight ? const Color(0xFF065F46) : Colors.greenAccent,
            );
          } else {
            stepBgColor = isLight ? const Color(0xFFF3F4F6) : Colors.white.withOpacity(0.04);
            stepBorderColor = isLight ? const Color(0xFFE5E7EB) : Colors.white12;
            stepChild = AppText(
              '${index + 1}',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isLight ? AppColors.secondaryText : Colors.white54,
            );
          }

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ref.read(builderViewModelProvider.notifier).setStep(index);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: AppDesign.durationFast,
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: stepBgColor,
                            border: Border.all(
                              color: stepBorderColor,
                              width: 1.5,
                            ),
                            boxShadow: isActive ? AppDesign.glowShadow(isLight ? const Color(0xFF2563EB) : AppColors.navyAccent) : null,
                          ),
                          child: Center(child: stepChild),
                        ),
                        const SizedBox(height: 6),
                        AppText(
                          stepTitles[index],
                          fontSize: 9,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          color: isActive 
                              ? (isLight ? const Color(0xFF2563EB) : AppColors.navyAccent) 
                              : (isLight ? AppColors.secondaryText : Colors.white38),
                          letterSpacing: 0.5,
                        ),
                      ],
                    ),
                  ),
                ),
                if (index < 4)
                  Container(
                    width: 20,
                    height: 1.5,
                    color: index < currentStep 
                        ? (isLight ? const Color(0xFF10B981) : const Color(0xFF1E3A2F)) 
                        : (isLight ? const Color(0xFFE5E7EB) : Colors.white12),
                    margin: const EdgeInsets.only(bottom: 14),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActiveFormStep(BuilderState state) {
    switch (state.currentStep) {
      case 0:
        return _buildTemplateSelector(state);
      case 1:
        return _buildCoupleDetailsForm(state);
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

  Widget _buildTemplateSelector(BuilderState state) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTitle(
          'Step 1: Select Design Template',
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: isLight ? AppColors.primaryText : Colors.white,
        ),
        const SizedBox(height: 8),
        AppBody(
          'Choose the premium theme style for your digital wedding card. You can toggle this dynamically at any time.',
          color: isLight ? AppColors.secondaryText : Colors.white54,
          fontSize: 12,
        ),
        const SizedBox(height: 24),
        
        if (state.availableTemplates.isEmpty) ...[
          _buildTemplateItem(
            id: 1,
            title: "Classic Mandala (Gold & Red)",
            desc: "Rich dark royal red with golden concentric patterns and luxury Sanskrit headers.",
            selectedId: state.invitation.selectedTemplateId,
            primaryColor: const Color(0xFF5B0000),
            secondaryColor: const Color(0xFFD4AF37),
          ),
          const SizedBox(height: 16),
          _buildTemplateItem(
            id: 2,
            title: "Royal Peacock (Maroon & Teal)",
            desc: "Elegant deep maroon backdrop complemented by teal peacock elements and gold frames.",
            selectedId: state.invitation.selectedTemplateId,
            primaryColor: const Color(0xFF380208),
            secondaryColor: const Color(0xFFD4AF37),
          ),
          const SizedBox(height: 16),
          _buildTemplateItem(
            id: 3,
            title: "Rose Gold (Minimalist Floral)",
            desc: "Beautiful blush rose gold shimmers bordered with detailed thin floral leafy branches.",
            selectedId: state.invitation.selectedTemplateId,
            primaryColor: const Color(0xFFFFF0F2),
            secondaryColor: const Color(0xFF4A3437),
          ),
        ] else
          ...state.availableTemplates.map((t) {
            final primaryColor = HexColor.fromHex(t.primaryColorHex);
            final secondaryColor = HexColor.fromHex(t.secondaryColorHex);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildTemplateItem(
                id: t.id,
                title: t.title,
                desc: t.description,
                selectedId: state.invitation.selectedTemplateId,
                primaryColor: primaryColor,
                secondaryColor: secondaryColor,
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
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    final isSelected = id == selectedId;
    String collection = 'Modern';
    if ([1, 2, 4, 5, 6].contains(id)) collection = 'Royal';
    else if ([7, 8, 9].contains(id)) collection = 'Luxury';
    else if ([3, 10, 11, 12].contains(id)) collection = 'Floral';

    final isLight = Theme.of(context).brightness == Brightness.light;
    return InkWell(
      onTap: () {
        ref.read(builderViewModelProvider.notifier).selectTemplate(id);
      },
      borderRadius: AppDesign.borderMedium,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isLight
              ? (isSelected ? const Color(0xFF2563EB).withOpacity(0.06) : Colors.white)
              : const Color(0xFF1E2638).withOpacity(isSelected ? 0.95 : 0.6),
          borderRadius: AppDesign.borderMedium,
          border: Border.all(
            color: isSelected
                ? (isLight ? const Color(0xFF2563EB) : AppColors.navyAccent)
                : (isLight ? AppColors.border : Colors.white.withOpacity(0.04)),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected ? AppDesign.glowShadow(isLight ? const Color(0xFF2563EB) : AppColors.navyAccent) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                ),
                border: Border.all(color: Colors.white24, width: 0.5),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: secondaryColor,
                      border: Border.all(color: Colors.black26, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ],
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
                  Row(
                    children: [
                      AppText(
                        title,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? (isLight ? const Color(0xFF2563EB) : AppColors.navyAccent) : (isLight ? AppColors.primaryText : Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: AppText(
                          collection.toUpperCase(),
                          color: isSelected ? (isLight ? const Color(0xFF2563EB).withOpacity(0.8) : AppColors.navyAccent.withOpacity(0.8)) : Colors.white38,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AppBody(
                    desc,
                    color: isLight ? AppColors.mutedText : Colors.white54,
                    fontSize: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? (isLight ? const Color(0xFF2563EB) : AppColors.navyAccent) : Colors.white24,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoupleDetailsForm(BuilderState state) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Form(
      key: _formKeyStep2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTitle(
            "Step 2: Couple Details",
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: isLight ? AppColors.primaryText : Colors.white,
          ),
          const SizedBox(height: 16),
          // Custom Photo Upload Discovery Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isLight ? AppColors.accentGold.withOpacity(0.08) : AppColors.navyAccent.withOpacity(0.05),
              borderRadius: AppDesign.borderMedium,
              border: Border.all(color: AppColors.accentGold.withOpacity(0.3), width: 1.0),
            ),
            child: Row(
              children: [
                const Icon(Icons.photo_library_outlined, color: AppColors.accentGold, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        '📸 Supports Custom Photos',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentGold,
                        preventTranslation: true,
                      ),
                      const SizedBox(height: 2),
                      AppBody(
                        'Upload photos of the bride and groom to render them inside the beautiful decorative gold frames of your selected theme.',
                        fontSize: 10,
                        color: isLight ? AppColors.secondaryText : Colors.white70,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          AppTextField(
            controller: _brideController,
            label: "BRIDE'S NAME",
            hintText: "Enter Bride's Name",
            onChanged: (val) {
              ref.read(builderViewModelProvider.notifier).updateBrideName(val);
            },
            validator: (value) => value == null || value.trim().isEmpty ? 'Bride name is required' : null,
          ),
          const SizedBox(height: 16),

          _buildPhotoUploadField(
            label: "BRIDE'S PHOTO",
            imageUrl: state.invitation.brideImageUrl,
            onUpload: () async {
              final path = await platform_export.ExportService.pickImage();
              if (path != null) {
                ref.read(builderViewModelProvider.notifier).updateBrideImageUrl(path);
              }
            },
            onDelete: () {
              ref.read(builderViewModelProvider.notifier).updateBrideImageUrl('');
            },
          ),
          const SizedBox(height: 24),

          AppTextField(
            controller: _groomController,
            label: "GROOM'S NAME",
            hintText: "Enter Groom's Name",
            onChanged: (val) {
              ref.read(builderViewModelProvider.notifier).updateGroomName(val);
            },
            validator: (value) => value == null || value.trim().isEmpty ? 'Groom name is required' : null,
          ),
          const SizedBox(height: 16),

          _buildPhotoUploadField(
            label: "GROOM'S PHOTO",
            imageUrl: state.invitation.groomImageUrl,
            onUpload: () async {
              final path = await platform_export.ExportService.pickImage();
              if (path != null) {
                ref.read(builderViewModelProvider.notifier).updateGroomImageUrl(path);
              }
            },
            onDelete: () {
              ref.read(builderViewModelProvider.notifier).updateGroomImageUrl('');
            },
          ),
          const SizedBox(height: 24),

          AppTextField(
            controller: _messageController,
            label: "PERSONAL WELCOME MESSAGE (OPTIONAL)",
            hintText: "e.g. Together with our families, we invite you...",
            maxLines: 3,
            onChanged: (val) {
              ref.read(builderViewModelProvider.notifier).updatePersonalMessage(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUploadField({
    required String label,
    required String imageUrl,
    required VoidCallback onUpload,
    required VoidCallback onDelete,
  }) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    ImageProvider? imageProvider;
    if (imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('data:image') || !imageUrl.startsWith('http')) {
        imageProvider = getCachedMemoryImage(imageUrl);
      } else {
        imageProvider = NetworkImage(imageUrl);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: AppColors.navyAccent,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isLight ? AppColors.inputFill : const Color(0xFF1E2638),
            borderRadius: AppDesign.borderSmall,
            border: Border.all(color: isLight ? AppColors.border : Colors.white10),
          ),
          child: Row(
            children: [
              if (imageProvider != null) ...[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.navyAccent, width: 1.5),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        'Photo Uploaded Successfully',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                        preventTranslation: true,
                      ),
                      const SizedBox(height: 2),
                      AppBody(
                        'Ready to render in templates',
                        fontSize: 10,
                        color: isLight ? AppColors.secondaryText : Colors.white54,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                  onPressed: onDelete,
                ),
              ] else ...[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isLight ? Colors.white : Colors.white.withOpacity(0.04),
                    border: Border.all(color: isLight ? AppColors.border : Colors.white10, width: 1.5),
                  ),
                  child: Icon(Icons.person_outline, color: isLight ? AppColors.secondaryText : Colors.white38, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'No Photo Selected',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isLight ? AppColors.primaryText : Colors.white70,
                      ),
                      const SizedBox(height: 2),
                      AppBody(
                        'Optional couple details photo',
                        fontSize: 10,
                        color: isLight ? AppColors.mutedText : Colors.white38,
                      ),
                    ],
                  ),
                ),
                AppButton(
                  label: 'Upload',
                  type: AppButtonType.outlined,
                  onPressed: onUpload,
                  height: 32,
                  width: 80,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleVenueForm(BuilderState state) {
    final dateDisplay = DateFormat('MMMM d, y').format(state.invitation.weddingDate);
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Form(
      key: _formKeyStep3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTitle(
            "Step 3: Event Logistics",
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: isLight ? AppColors.primaryText : Colors.white,
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "WEDDING DATE",
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: (isLight ? AppColors.secondaryText : AppColors.navyAccent).withOpacity(0.85),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context, ref, state.invitation.weddingDate),
                      borderRadius: AppDesign.borderSmall,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isLight ? const Color(0xFFF9FAFB) : const Color(0xFF1E2638),
                          borderRadius: AppDesign.borderSmall,
                          border: Border.all(color: isLight ? AppColors.border : Colors.white10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              dateDisplay,
                              color: isLight ? AppColors.primaryText : Colors.white,
                              fontSize: 14,
                            ),
                            Icon(Icons.calendar_month, color: isLight ? AppColors.accentGold : AppColors.navyAccent, size: 18),
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
                    AppText(
                      "WEDDING TIME",
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: (isLight ? AppColors.secondaryText : AppColors.navyAccent).withOpacity(0.85),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectTime(context, ref, state.invitation.weddingTime),
                      borderRadius: AppDesign.borderSmall,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isLight ? const Color(0xFFF9FAFB) : const Color(0xFF1E2638),
                          borderRadius: AppDesign.borderSmall,
                          border: Border.all(color: isLight ? AppColors.border : Colors.white10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              state.invitation.weddingTime,
                              color: isLight ? AppColors.primaryText : Colors.white,
                              fontSize: 14,
                            ),
                            Icon(Icons.access_time, color: isLight ? AppColors.accentGold : AppColors.navyAccent, size: 18),
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

          AppTextField(
            controller: _venueNameController,
            label: "VENUE HALL NAME",
            hintText: "e.g. Royal Ballroom, Grand Palace Resort",
            onChanged: (val) {
              ref.read(builderViewModelProvider.notifier).updateVenueName(val);
            },
            validator: (value) => value == null || value.trim().isEmpty ? 'Venue name is required' : null,
          ),
          const SizedBox(height: 20),

          AppTextField(
            controller: _venueAddressController,
            label: "VENUE ADDRESS / TOWN",
            hintText: "e.g. Plot 14, Ring Road, New Delhi",
            maxLines: 2,
            onChanged: (val) {
              ref.read(builderViewModelProvider.notifier).updateVenueAddress(val);
            },
            validator: (value) => value == null || value.trim().isEmpty ? 'Venue address is required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildExportPanel(BuilderState state) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTitle(
          "Step 4: Review & Export",
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: isLight ? AppColors.primaryText : Colors.white,
        ),
        const SizedBox(height: 8),
        AppBody(
          "Everything is set! You can now download your high-resolution card as an image or generate a unique digital link to share with your guests.",
          color: isLight ? AppColors.secondaryText : Colors.white54,
          fontSize: 12,
        ),
        const SizedBox(height: 32),

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
              await ref.read(activeInvitationIdsProvider.notifier).markAsActive(state.invitation.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PNG successfully saved to downloads!'), backgroundColor: Colors.green),
              );
            }
          },
        ),

        const SizedBox(height: 24),

        _buildActionCard(
          icon: Icons.link_outlined,
          title: "Generate Web invitation Link",
          desc: "Creates a unique dynamic link that guests can visit to view the card reactively.",
          actionLabel: "Generate URL",
          isLoading: state.isSaving,
          onAction: () async {
            final String hostUrl = Uri.base.origin + Uri.base.path;
            await ref.read(builderViewModelProvider.notifier).saveAndGenerateLink(hostUrl);
            await ref.read(activeInvitationIdsProvider.notifier).markAsActive(state.invitation.id);
          },
        ),

        if (state.generatedUrl != null) ...[
          const SizedBox(height: 20),
          AppCard(
            padding: const EdgeInsets.all(16),
            borderColor: AppColors.navyAccent.withOpacity(0.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  "SHAREABLE URL GENERATED",
                  color: AppColors.navyAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        state.generatedUrl!,
                        style: TextStyle(
                          color: isLight ? AppColors.secondaryText : Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16, color: AppColors.navyAccent),
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
    final isLight = Theme.of(context).brightness == Brightness.light;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.navyAccent, size: 22),
              const SizedBox(width: 12),
              AppHeading(title, color: isLight ? AppColors.primaryText : Colors.white),
            ],
          ),
          const SizedBox(height: 8),
          AppBody(desc, color: isLight ? AppColors.secondaryText : Colors.white54),
          const SizedBox(height: 16),
          AppButton(
            label: actionLabel,
            onPressed: onAction,
            isLoading: isLoading,
            width: double.infinity,
            height: 44,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuilderState state) {
    final showBack = state.currentStep > 0;
    final isLast = state.currentStep == 4;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Row(
      children: [
        if (showBack) ...[
          Expanded(
            child: AppButton(
              label: 'Back',
              type: AppButtonType.outlined,
              backgroundColor: isLight ? const Color(0xFF2563EB) : AppColors.navyAccent,
              foregroundColor: isLight ? const Color(0xFF2563EB) : AppColors.navyAccent,
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
              backgroundColor: isLight ? const Color(0xFF2563EB) : AppColors.navyAccent,
              foregroundColor: isLight ? Colors.white : Colors.black87,
              onPressed: () {
                if (state.currentStep == 1 && !_formKeyStep2.currentState!.validate()) {
                  return;
                }
                if (state.currentStep == 2 && !_formKeyStep3.currentState!.validate()) {
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
