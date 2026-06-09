import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

import 'widgets/landing_background.dart';
import 'widgets/landing_header.dart';
import 'widgets/landing_hero_section.dart';
import 'widgets/landing_ledger_section.dart';
import 'widgets/showcase_title_and_tabs.dart';
import 'widgets/showcase_grid_section.dart';
import 'widgets/landing_features_section.dart';
import 'widgets/landing_footer.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Isolate static/heavy background repaints
          const Positioned.fill(
            child: LandingBackground(),
          ),

          // Main contents (using Sliver-based CustomScrollView for lazy loading & reveal performance)
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(
                    child: LandingHeader(),
                  ),
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate.fixed([
                        LandingHeroSection(),
                        LandingLedgerSection(),
                      ]),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: ShowcaseTitleAndTabs(),
                  ),
                  const ShowcaseGridSection(),
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate.fixed([
                        SizedBox(height: 64),
                        LandingFeaturesSection(),
                        SizedBox(height: 80),
                        LandingFooter(),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
