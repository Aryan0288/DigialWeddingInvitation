import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/app_text.dart';
import '../../../viewmodels/builder_viewmodel.dart';
import '../../../../data/repositories/invitation_repository.dart';

class ReviewExportSection extends ConsumerWidget {
  final ScreenshotController screenshotController;

  const ReviewExportSection({
    super.key,
    required this.screenshotController,
  });

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String desc,
    required String actionLabel,
    required VoidCallback onAction,
    bool isLoading = false,
    required bool isLight,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accent, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: AppHeading(
                  title, 
                  color: isLight ? AppColors.primaryText : Colors.white,
                ),
              ),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(builderViewModelProvider);
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
          isLight: isLight,
          onAction: () async {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Capturing high-resolution image...'), duration: Duration(seconds: 1)),
            );
            final success = await ref.read(builderViewModelProvider.notifier).downloadPNG(screenshotController);
            if (success && context.mounted) {
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
          title: "Generate Web Invitation Link",
          desc: "Creates a unique dynamic link that guests can visit to view the card reactively.",
          actionLabel: "Generate URL",
          isLoading: state.isSaving,
          isLight: isLight,
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
            borderColor: AppColors.accent.withOpacity(0.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  "SHAREABLE URL GENERATED",
                  color: AppColors.accent,
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
                      icon: const Icon(Icons.copy, size: 16, color: AppColors.accent),
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
}
