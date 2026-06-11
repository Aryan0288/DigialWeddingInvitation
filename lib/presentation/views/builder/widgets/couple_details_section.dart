import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/export_service.dart' as platform_export;
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/templates_widgets.dart';
import '../../../viewmodels/builder_viewmodel.dart';

class CoupleDetailsSection extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController brideController;
  final TextEditingController groomController;
  final TextEditingController messageController;

  const CoupleDetailsSection({
    super.key,
    required this.formKey,
    required this.brideController,
    required this.groomController,
    required this.messageController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brideImageUrl = ref.watch(
        builderViewModelProvider.select((s) => s.invitation.brideImageUrl));
    final groomImageUrl = ref.watch(
        builderViewModelProvider.select((s) => s.invitation.groomImageUrl));

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          _StepSectionHeader(
            stepNum: '02',
            title: 'Couple Details',
            subtitle: 'Names & photos render live on your invitation card',
          ),
          const SizedBox(height: 20),

          // Bride card
          _ProfileCard(
            label: "Bride's Details",
            icon: Icons.woman_outlined,
            iconColor: const Color(0xFFE91E8C),
            imageUrl: brideImageUrl,
            nameController: brideController,
            nameLabel: "BRIDE'S NAME",
            nameHint: "e.g. Priya Sharma",
            nameValidator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Bride name is required' : null,
            onNameChanged: (val) =>
                ref.read(builderViewModelProvider.notifier).updateBrideName(val),
            onUpload: () async {
              final path = await platform_export.ExportService.pickImage();
              if (path != null) {
                ref
                    .read(builderViewModelProvider.notifier)
                    .updateBrideImageUrl(path);
              }
            },
            onDeletePhoto: () => ref
                .read(builderViewModelProvider.notifier)
                .updateBrideImageUrl(''),
          ),
          const SizedBox(height: 16),

          // Groom card
          _ProfileCard(
            label: "Groom's Details",
            icon: Icons.man_outlined,
            iconColor: const Color(0xFF1565C0),
            imageUrl: groomImageUrl,
            nameController: groomController,
            nameLabel: "GROOM'S NAME",
            nameHint: "e.g. Aryan Mehta",
            nameValidator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Groom name is required' : null,
            onNameChanged: (val) =>
                ref.read(builderViewModelProvider.notifier).updateGroomName(val),
            onUpload: () async {
              final path = await platform_export.ExportService.pickImage();
              if (path != null) {
                ref
                    .read(builderViewModelProvider.notifier)
                    .updateGroomImageUrl(path);
              }
            },
            onDeletePhoto: () => ref
                .read(builderViewModelProvider.notifier)
                .updateGroomImageUrl(''),
          ),
          const SizedBox(height: 16),

          // Personal message card
          Container(
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
                        color: AppColors.accentGold.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.format_quote_rounded,
                          color: AppColors.accentGold, size: 16),
                    ),
                    const SizedBox(width: 10),
                    const AppText(
                      'Personal Message',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.border.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const AppBody(
                        'Optional',
                        fontSize: 9,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: messageController,
                  label: 'WELCOME MESSAGE',
                  hintText:
                      'e.g. Together with our families, we invite you to share our joy…',
                  maxLines: 3,
                  onChanged: (val) => ref
                      .read(builderViewModelProvider.notifier)
                      .updatePersonalMessage(val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile card (photo upload + name field) ────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final String imageUrl;
  final TextEditingController nameController;
  final String nameLabel;
  final String nameHint;
  final String? Function(String?) nameValidator;
  final void Function(String) onNameChanged;
  final VoidCallback onUpload;
  final VoidCallback onDeletePhoto;

  const _ProfileCard({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.imageUrl,
    required this.nameController,
    required this.nameLabel,
    required this.nameHint,
    required this.nameValidator,
    required this.onNameChanged,
    required this.onUpload,
    required this.onDeletePhoto,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('data:image') || !imageUrl.startsWith('http')) {
        imageProvider = getCachedMemoryImage(imageUrl);
      } else {
        // 64px avatar — decode at ~2x instead of the full-resolution source.
        imageProvider =
            ResizeImage(NetworkImage(imageUrl), width: 128, height: 128);
      }
    }
    final hasPhoto = imageProvider != null;

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
          // Card header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 10),
              AppText(
                label,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Photo upload row
          Row(
            children: [
              // Avatar circle
              GestureDetector(
                onTap: hasPhoto ? null : onUpload,
                child: Stack(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasPhoto
                            ? null
                            : AppColors.background,
                        border: Border.all(
                          color: hasPhoto
                              ? AppColors.accent.withOpacity(0.5)
                              : AppColors.border,
                          width: hasPhoto ? 2 : 1.5,
                        ),
                        image: imageProvider != null
                            ? DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: hasPhoto
                          ? null
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined,
                                    color: AppColors.mutedText, size: 18),
                                const SizedBox(height: 2),
                                Text(
                                  'Photo',
                                  style: TextStyle(
                                    color: AppColors.mutedText,
                                    fontSize: 8,
                                  ),
                                ),
                              ],
                            ),
                    ),
                    if (hasPhoto)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: onDeletePhoto,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.error,
                            ),
                            child: const Icon(Icons.close_rounded,
                                color: Colors.white, size: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Upload status + button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasPhoto) ...[
                      const AppText(
                        'Photo Uploaded',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                        preventTranslation: true,
                      ),
                      const SizedBox(height: 2),
                      AppBody(
                        'Renders inside card frames',
                        fontSize: 10,
                        color: AppColors.secondaryText,
                      ),
                    ] else ...[
                      AppText(
                        'No photo selected',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryText,
                      ),
                      const SizedBox(height: 2),
                      AppBody(
                        'Optional — adds personal touch',
                        fontSize: 10,
                        color: AppColors.mutedText,
                      ),
                      const SizedBox(height: 8),
                      AppButton(
                        label: 'Upload Photo',
                        type: AppButtonType.outlined,
                        icon: Icons.upload_rounded,
                        onPressed: onUpload,
                        height: 30,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Name field
          AppTextField(
            controller: nameController,
            label: nameLabel,
            hintText: nameHint,
            onChanged: onNameChanged,
            validator: nameValidator,
          ),
        ],
      ),
    );
  }
}

// ── Shared step section header (reused across form steps) ───────────────────

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
