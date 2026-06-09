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
    final brideImageUrl = ref.watch(builderViewModelProvider.select((s) => s.invitation.brideImageUrl));
    final groomImageUrl = ref.watch(builderViewModelProvider.select((s) => s.invitation.groomImageUrl));
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Form(
      key: formKey,
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
              color: isLight 
                  ? AppColors.accent.withOpacity(0.06) 
                  : AppColors.accent.withOpacity(0.04),
              borderRadius: AppDesign.borderMedium,
              border: Border.all(
                color: AppColors.accent.withOpacity(0.2), 
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.photo_library_outlined, color: AppColors.accent, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        '📸 Supports Custom Photos',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                        preventTranslation: true,
                      ),
                      const SizedBox(height: 2),
                      AppBody(
                        'Upload photos of the bride and groom to render them inside the beautiful decorative frames of your selected theme.',
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
            controller: brideController,
            label: "BRIDE'S NAME",
            hintText: "Enter Bride's Name",
            onChanged: (val) {
              ref.read(builderViewModelProvider.notifier).updateBrideName(val);
            },
            validator: (value) => value == null || value.trim().isEmpty ? 'Bride name is required' : null,
          ),
          const SizedBox(height: 16),

          _buildPhotoUploadField(
            context,
            ref,
            label: "BRIDE'S PHOTO",
            imageUrl: brideImageUrl,
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
            controller: groomController,
            label: "GROOM'S NAME",
            hintText: "Enter Groom's Name",
            onChanged: (val) {
              ref.read(builderViewModelProvider.notifier).updateGroomName(val);
            },
            validator: (value) => value == null || value.trim().isEmpty ? 'Groom name is required' : null,
          ),
          const SizedBox(height: 16),

          _buildPhotoUploadField(
            context,
            ref,
            label: "GROOM'S PHOTO",
            imageUrl: groomImageUrl,
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
            controller: messageController,
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

  Widget _buildPhotoUploadField(
    BuildContext context,
    WidgetRef ref, {
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
        AppLabel(label),
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
                    border: Border.all(color: AppColors.accent, width: 1.5),
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
}
