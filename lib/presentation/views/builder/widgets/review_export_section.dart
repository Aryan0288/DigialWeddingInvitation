import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text.dart';
import '../../../viewmodels/builder_viewmodel.dart';
import '../../../../data/repositories/invitation_repository.dart';

class ReviewExportSection extends ConsumerWidget {
  final ScreenshotController screenshotController;

  const ReviewExportSection({super.key, required this.screenshotController});

  // Header decoration depends only on static theme colors — allocate once.
  static final BoxDecoration _headerDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.accentGold.withOpacity(0.08),
        AppColors.accent.withOpacity(0.04),
      ],
    ),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.accentGold.withOpacity(0.25),
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitationId =
        ref.watch(builderViewModelProvider.select((s) => s.invitation.id));
    final isSaving =
        ref.watch(builderViewModelProvider.select((s) => s.isSaving));
    final generatedUrl =
        ref.watch(builderViewModelProvider.select((s) => s.generatedUrl));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Celebratory header ──────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: _headerDecoration,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration_outlined,
                  color: AppColors.accentGold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppTitle(
                      'Your Invitation Is Ready!',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                    const SizedBox(height: 3),
                    AppBody(
                      'Download as a high-res image or generate a shareable web link for your guests.',
                      color: AppColors.secondaryText,
                      fontSize: 11,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Export PNG card ─────────────────────────────────────────────
        _ExportCard(
          icon: Icons.image_outlined,
          iconBgColor: const Color(0xFF7B61FF).withOpacity(0.10),
          iconColor: const Color(0xFF7B61FF),
          title: 'Download as Image',
          description:
              'Saves a 1080 × 1920 px PNG — perfect for WhatsApp, Instagram, and print.',
          buttonLabel: 'Export PNG',
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Capturing high-resolution image…'),
                duration: Duration(seconds: 1),
              ),
            );
            final success = await ref
                .read(builderViewModelProvider.notifier)
                .downloadPNG(screenshotController);
            if (success) {
              await ref
                  .read(activeInvitationIdsProvider.notifier)
                  .markAsActive(invitationId);
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('PNG saved to downloads!'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
        ),
        const SizedBox(height: 12),

        // ── Generate link card ──────────────────────────────────────────
        _ExportCard(
          icon: Icons.link_rounded,
          iconBgColor: AppColors.success.withOpacity(0.10),
          iconColor: AppColors.success,
          title: 'Generate Web Link',
          description:
              'Creates a unique URL that guests can open on any device to view your invitation live.',
          buttonLabel: 'Generate URL',
          isLoading: isSaving,
          onPressed: () async {
            final hostUrl = Uri.base.origin + Uri.base.path;
            await ref
                .read(builderViewModelProvider.notifier)
                .saveAndGenerateLink(hostUrl);
            await ref
                .read(activeInvitationIdsProvider.notifier)
                .markAsActive(invitationId);
          },
        ),

        // ── Generated URL display ───────────────────────────────────────
        if (generatedUrl != null) ...[
          const SizedBox(height: 16),
          _ShareLinkCard(url: generatedUrl),
        ],

        const SizedBox(height: 24),

        // ── Next step hint ──────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBAE6FD)),
          ),
          child: Row(
            children: [
              const Icon(Icons.bar_chart_rounded,
                  color: Color(0xFF0EA5E9), size: 16),
              const SizedBox(width: 10),
              const Expanded(
                child: AppBody(
                  'Continue to Step 5 to track RSVP responses in real-time.',
                  fontSize: 11,
                  color: Color(0xFF0369A1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Export action card ──────────────────────────────────────────────────────

class _ExportCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;
  final bool isLoading;

  const _ExportCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
                const SizedBox(height: 3),
                AppBody(
                  description,
                  fontSize: 11,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AppButton(
            label: buttonLabel,
            onPressed: onPressed,
            isLoading: isLoading,
            height: 36,
            width: 96,
          ),
        ],
      ),
    );
  }
}

// ── Shareable link display card ─────────────────────────────────────────────

class _ShareLinkCard extends StatelessWidget {
  final String url;
  const _ShareLinkCard({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 8),
              const AppText(
                'SHAREABLE LINK READY',
                color: AppColors.success,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                preventTranslation: true,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    url,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: url));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.copy_rounded,
                        color: AppColors.accent, size: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
