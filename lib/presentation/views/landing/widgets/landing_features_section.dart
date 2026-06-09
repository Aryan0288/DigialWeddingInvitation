import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/common/app_text.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/app_section_title.dart';
import '../../../widgets/common/scroll_entrance.dart';

class LandingFeaturesSection extends StatelessWidget {
  const LandingFeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppSectionTitle(
          title: 'Features Designed For Your Convenience',
          subtitle: 'Why Choose Vivah',
        ),
        const SizedBox(height: 48),
        Wrap(
          spacing: 24,
          runSpacing: 24,
          alignment: WrapAlignment.center,
          children: const [
            ScrollEntrance(
              type: ScrollEntranceType.slideUp,
              delayIndex: 0,
              child: _CustomFeatureCard(
                icon: Icons.palette_outlined,
                title: 'Curated Cultural Themes',
                desc: 'Select from our wide array of Royal, Floral, Luxury, and Modern collections customized with premium vectors.',
              ),
            ),
            ScrollEntrance(
              type: ScrollEntranceType.slideUp,
              delayIndex: 1,
              child: _CustomFeatureCard(
                icon: Icons.auto_awesome_outlined,
                title: 'Live Responsive Previews',
                desc: 'Fill in details and instantly view updates on a realistic 9:16 vertical workspace card mockup.',
              ),
            ),
            ScrollEntrance(
              type: ScrollEntranceType.slideUp,
              delayIndex: 2,
              child: _CustomFeatureCard(
                icon: Icons.save_alt_outlined,
                title: 'High-Res Image Captures',
                desc: 'Export invites as crisp 1080x1920 portrait PNG files suitable for sharing directly on WhatsApp or social media.',
              ),
            ),
            ScrollEntrance(
              type: ScrollEntranceType.slideUp,
              delayIndex: 3,
              child: _CustomFeatureCard(
                icon: Icons.sync_alt_outlined,
                title: 'Real-Time RSVP Stream',
                desc: 'Collect confirmations via live web links with real-time updates and headcounts mapped to your Host dashboard.',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CustomFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _CustomFeatureCard({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return AppCard(
      width: 260,
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.navyAccent.withOpacity(0.08),
            ),
            child: Icon(icon, color: AppColors.navyAccent, size: 26),
          ),
          const SizedBox(height: 20),
          AppHeading(
            title,
            color: isLight ? AppColors.primaryText : Colors.white,
            textAlign: TextAlign.center,
            isSerif: true,
          ),
          const SizedBox(height: 8),
          AppBody(
            desc,
            color: isLight ? AppColors.secondaryText : Colors.white54,
            fontSize: 11,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
