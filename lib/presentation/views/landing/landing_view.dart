import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/invitation_model.dart';
import '../../../data/models/remote_template_model.dart';
import '../../../data/repositories/invitation_repository.dart';
import '../../widgets/templates_widgets.dart';
import '../../widgets/common/app_text.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_section_title.dart';
import '../../widgets/common/scroll_entrance.dart';
import '../../../core/theme/app_theme.dart';
import '../../viewmodels/landing_viewmodel.dart';

class LandingView extends ConsumerStatefulWidget {
  const LandingView({super.key});

  @override
  ConsumerState<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends ConsumerState<LandingView> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 50),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  String _getCollectionForId(int id) {
    if ([1, 2, 4, 5, 6].contains(id)) return 'Royal';
    if ([7, 8, 9].contains(id)) return 'Luxury';
    if ([3, 10, 11, 12].contains(id)) return 'Floral';
    return 'Modern';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    final savedInvitations = ref.watch(draftsProvider);
    final publishedKeys = ref.watch(mockPublishedKeysProvider);
    final activeIds = ref.watch(activeInvitationIdsProvider);

    final activeInvitations = savedInvitations.where((inv) {
      final isPublished = publishedKeys.contains(inv.id);
      final isActivated = activeIds.contains(inv.id);
      return isPublished || isActivated;
    }).toList();

    final landingState = ref.watch(landingViewModelProvider);
    final filteredTemplates = landingState.templates.where((t) {
      if (landingState.selectedCollection == 'All') return true;
      return _getCollectionForId(t.id) == landingState.selectedCollection;
    }).toList();

    final isLight = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Elegant background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isLight 
                      ? [
                          AppColors.sectionBackground,
                          AppColors.background,
                          AppColors.sectionBackground,
                        ]
                      : [
                          AppColors.navySurface,
                          AppColors.navyBackground,
                          const Color(0xFF02040A),
                        ],
                ),
              ),
            ),
          ),

          // Glowing radial lights
          Positioned(
            top: size.height * 0.1,
            left: size.width * 0.1,
            child: Container(
              key: const ValueKey('glow_light_1'),
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.navyAccent.withOpacity(0.015),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navyAccent.withOpacity(0.06),
                    blurRadius: 150,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          // Rotating background decoration mandalas
          Positioned(
            top: -120,
            right: -120,
            child: RotationTransition(
              turns: _rotationController,
              child: SizedBox(
                width: 450,
                height: 450,
                child: CustomPaint(
                  painter: MandalaPainter(color: AppColors.navyAccent.withOpacity(0.035)),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -180,
            left: -180,
            child: RotationTransition(
              turns: _rotationController,
              child: SizedBox(
                width: 500,
                height: 500,
                child: CustomPaint(
                  painter: MandalaPainter(color: AppColors.navyAccent.withOpacity(0.025)),
                ),
              ),
            ),
          ),

          // Main contents (using Sliver-based CustomScrollView for lazy loading & reveal performance)
          Positioned.fill(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(context),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildHeroSection(context, isMobile, size),
                      const SizedBox(height: 20),
                      _buildLedgerSection(activeInvitations, publishedKeys),
                      const SizedBox(height: 32),
                      _buildShowcaseTitleAndTabs(isMobile),
                    ]),
                  ),
                ),
                if (landingState.loadingTemplates)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 60.0),
                        child: CircularProgressIndicator(color: AppColors.navyAccent),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 2 : 4,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.58,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final t = filteredTemplates[index];
                          return _buildShowcaseItem(t, index, isMobile);
                        },
                        childCount: filteredTemplates.length,
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 64),
                      _buildFeaturesSection(isMobile),
                      const SizedBox(height: 80),
                      _buildFooter(),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
        color: isLight ? AppColors.sectionBackground : AppColors.navySurface.withOpacity(0.3),
        border: Border(bottom: BorderSide(color: isLight ? AppColors.border : Colors.white.withOpacity(0.03))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.navyAccent, width: 1),
                ),
                child: const Icon(Icons.favorite, color: AppColors.navyAccent, size: 14),
              ),
              const SizedBox(width: 10),
              const AppText(
                'VIVAH',
                color: AppColors.navyAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                isSerif: true,
              ),
            ],
          ),
          AppButton(
            label: 'Start Creating',
            onPressed: () => context.go('/builder'),
            height: 38,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isMobile, Size size) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final titleText = RichText(
      textAlign: isMobile ? TextAlign.center : TextAlign.start,
      text: TextSpan(
        style: GoogleFonts.playfairDisplay(
          fontSize: isMobile ? 36 : 56,
          fontWeight: FontWeight.w300,
          color: isLight ? AppColors.primaryText : Colors.white,
          height: 1.25,
        ),
        children: [
          const TextSpan(text: 'Craft Elegant\nDigital '),
          TextSpan(
            text: 'Wedding Cards',
            style: TextStyle(
              color: AppColors.accentGold,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );

    final subtitleText = AppText(
      'ELEGANT & SELF-SERVICE PLATFORM',
      fontSize: 11,
      letterSpacing: 4.0,
      fontWeight: FontWeight.w600,
      color: AppColors.navyAccent,
      textAlign: isMobile ? TextAlign.center : TextAlign.start,
    );

    final descText = AppBody(
      'Design luxury interactive invitations in minutes. Choose from our premium collections, customize detail fields, generate live links with real-time RSVP dashboards, and share high-resolution downloads with your guests.',
      color: isLight ? AppColors.secondaryText : Colors.white60,
      textAlign: isMobile ? TextAlign.center : TextAlign.start,
    );

    final ctaButton = AppButton(
      label: 'Create Free Card',
      onPressed: () => context.go('/builder'),
      icon: Icons.arrow_forward_rounded,
      width: 230,
      height: 52,
    );

    if (isMobile) {
      return ScrollEntrance(
        type: ScrollEntranceType.slideUp,
        delayIndex: 1,
        child: Column(
          children: [
            const SizedBox(height: 24),
            subtitleText,
            const SizedBox(height: 16),
            titleText,
            const SizedBox(height: 16),
            descText,
            const SizedBox(height: 32),
            ctaButton,
            const SizedBox(height: 48),
            _buildHeroCardStack(size),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: ScrollEntrance(
            type: ScrollEntranceType.slideUp,
            delayIndex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                subtitleText,
                const SizedBox(height: 20),
                titleText,
                const SizedBox(height: 20),
                Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: descText,
                ),
                const SizedBox(height: 36),
                ctaButton,
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: ScrollEntrance(
            type: ScrollEntranceType.scaleIn,
            delayIndex: 3,
            child: Center(
              child: _buildHeroCardStack(size),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCardStack(Size size) {
    final double cardWidth = 240;
    final double cardHeight = 426;

    final dummyInv = InvitationModel(
      id: 'dummy',
      brideName: 'Kareena',
      groomName: 'Saif',
      weddingDate: DateTime.now().add(const Duration(days: 90)),
      weddingTime: '19:00',
      venueName: 'The Taj Mahal Palace',
      venueAddress: 'Colaba, Mumbai, India',
      personalMessage: 'We request the honor of your presence.',
      selectedTemplateId: 4,
    );

    return SizedBox(
      height: 480,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform(
            transform: Matrix4.identity()
              ..translate(-50.0, 10.0, 0.0)
              ..rotateZ(-0.15),
            origin: const Offset(120, 213),
            child: _buildStackCardWrapper(
              width: cardWidth,
              height: cardHeight,
              child: RoseGoldFloralTemplate(invitation: _stubInvitation, isPreview: true),
            ),
          ),
          Transform(
            transform: Matrix4.identity()
              ..translate(50.0, 20.0, 0.0)
              ..rotateZ(0.15),
            origin: const Offset(120, 213),
            child: _buildStackCardWrapper(
              width: cardWidth,
              height: cardHeight,
              child: InvitationTemplateFactory.getTemplate(
                templateId: 4,
                invitation: dummyInv,
                isPreview: true,
              ),
            ),
          ),
          Transform(
            transform: Matrix4.identity()
              ..translate(0.0, -10.0, 0.0),
            child: _buildStackCardWrapper(
              width: cardWidth,
              height: cardHeight,
              child: GoldRedMandalaTemplate(invitation: _stubInvitation, isPreview: true),
            ),
          ),
        ],
      ),
    );
  }

  static final _stubInvitation = InvitationModel(
    id: 'stub',
    brideName: 'Devika',
    groomName: 'Rohan',
    weddingDate: DateTime.now().add(const Duration(days: 60)),
    weddingTime: '18:30',
    venueName: 'Grand Palace Hall',
    venueAddress: 'Main Palace Road, New Delhi',
    personalMessage: 'Love sparkles & celebrations await!',
    selectedTemplateId: 1,
  );

  Widget _buildStackCardWrapper({required double width, required double height, required Widget child}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.55),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 360,
          height: 640,
          child: child,
        ),
      ),
    );
  }

  Widget _buildLedgerSection(List<InvitationModel> invitations, Set<String> publishedKeys) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return ScrollEntrance(
      type: ScrollEntranceType.slideUp,
      delayIndex: 2,
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        borderColor: AppColors.navyAccent.withOpacity(0.12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.bookmark_added_outlined, color: AppColors.navyAccent, size: 20),
                SizedBox(width: 10),
                AppText(
                  'YOUR ACTIVE INVITATIONS',
                  color: AppColors.navyAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (invitations.isEmpty)
              _buildEmptyState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: invitations.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final inv = invitations[index];
                  final names = inv.brideName.isEmpty && inv.groomName.isEmpty
                      ? "Draft Invitation (Untitled)"
                      : "${inv.brideName} & ${inv.groomName}";
                  final dateStr = DateFormat('MMMM d, y').format(inv.weddingDate);
                  final isLive = publishedKeys.contains(inv.id);
    
                  return ScrollEntrance(
                    type: ScrollEntranceType.fadeIn,
                    delayIndex: index,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isLight ? AppColors.sectionBackground : Colors.white.withOpacity(0.02),
                        borderRadius: AppDesign.borderMedium,
                        border: Border.all(color: isLight ? AppColors.border : Colors.white.withOpacity(0.04)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    AppText(
                                      names,
                                      color: isLight ? AppColors.primaryText : Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      isSerif: true,
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isLive 
                                            ? (isLight ? const Color(0xFFD1FAE5) : const Color(0xFF1E3A2F)) 
                                            : (isLight ? const Color(0xFFF3F4F6) : const Color(0xFF2A2A2A)),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: AppText(
                                        isLive ? 'LIVE' : 'DRAFT',
                                        color: isLive 
                                            ? (isLight ? const Color(0xFF065F46) : Colors.greenAccent) 
                                            : (isLight ? const Color(0xFF374151) : Colors.white60),
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                AppBody(
                                  'Wedding Date: $dateStr • Venue: ${inv.venueName.isEmpty ? 'Not set' : inv.venueName}',
                                  color: isLight ? AppColors.secondaryText : Colors.white54,
                                  fontSize: 11,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          AppButton(
                            label: 'Track RSVPs',
                            type: AppButtonType.outlined,
                            icon: Icons.analytics_outlined,
                            onPressed: () => context.go('/builder?id=${inv.id}&step=4'),
                            height: 34,
                          ),
                          const SizedBox(width: 8),
                          AppButton(
                            label: 'Edit Card',
                            type: AppButtonType.outlined,
                            icon: Icons.edit_outlined,
                            onPressed: () => context.go('/builder?id=${inv.id}'),
                            height: 34,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isLight ? AppColors.sectionBackground : Colors.white.withOpacity(0.01),
        borderRadius: AppDesign.borderMedium,
        border: Border.all(color: isLight ? AppColors.border : Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentGold.withOpacity(0.08),
            ),
            child: const Icon(
              Icons.mail_outline_rounded,
              color: AppColors.accentGold,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppText(
                  "No Active Invitations",
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  isSerif: true,
                  color: AppColors.primaryText,
                  preventTranslation: true,
                ),
                const SizedBox(height: 2),
                AppBody(
                  "Publish an invitation or download its PNG to see it here.",
                  color: isLight ? AppColors.secondaryText : Colors.white54,
                  fontSize: 11,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowcaseTitleAndTabs(bool isMobile) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final landingState = ref.watch(landingViewModelProvider);
    return ScrollEntrance(
      type: ScrollEntranceType.slideUp,
      delayIndex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const AppSectionTitle(
            title: 'Choose Your Wedding Design',
            subtitle: 'Explore Premium Themes',
          ),
          const SizedBox(height: 32),
  
          // Collection Categories Filter Tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isLight ? AppColors.inputFill : AppColors.navySurface.withOpacity(0.6),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: isLight ? AppColors.border : Colors.white.withOpacity(0.04)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Royal', 'Luxury', 'Floral', 'Modern'].map((category) {
                  final isSelected = landingState.selectedCollection == category;
                  return GestureDetector(
                    onTap: () {
                      ref.read(landingViewModelProvider.notifier).selectCollection(category);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.navyAccent : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AppText(
                        category,
                        color: isSelected ? Colors.white : (isLight ? AppColors.secondaryText : Colors.white70),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildShowcaseItem(RemoteTemplateModel t, int index, bool isMobile) {
    final landingState = ref.watch(landingViewModelProvider);
    final dummyInv = _stubInvitation.copyWith(selectedTemplateId: t.id);

    return ScrollEntrance(
      type: ScrollEntranceType.slideAndScale,
      delayIndex: index % (isMobile ? 2 : 4), // Stagger index within a row
      child: _ShowcaseHoverCard(
        template: t,
        cardWidget: InvitationTemplateFactory.getTemplate(
          templateId: t.id,
          invitation: dummyInv,
          isPreview: true,
          availableTemplates: landingState.templates,
        ),
        onSelect: () => context.go('/builder?template=${t.id}'),
      ),
    );
  }

  Widget _buildFeaturesSection(bool isMobile) {
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
          children: [
            ScrollEntrance(
              type: ScrollEntranceType.slideUp,
              delayIndex: 0,
              child: _buildCustomFeatureCard(
                icon: Icons.palette_outlined,
                title: 'Curated Cultural Themes',
                desc: 'Select from our wide array of Royal, Floral, Luxury, and Modern collections customized with premium vectors.',
              ),
            ),
            ScrollEntrance(
              type: ScrollEntranceType.slideUp,
              delayIndex: 1,
              child: _buildCustomFeatureCard(
                icon: Icons.auto_awesome_outlined,
                title: 'Live Responsive Previews',
                desc: 'Fill in details and instantly view updates on a realistic 9:16 vertical workspace card mockup.',
              ),
            ),
            ScrollEntrance(
              type: ScrollEntranceType.slideUp,
              delayIndex: 2,
              child: _buildCustomFeatureCard(
                icon: Icons.save_alt_outlined,
                title: 'High-Res Image Captures',
                desc: 'Export invites as crisp 1080x1920 portrait PNG files suitable for sharing directly on WhatsApp or social media.',
              ),
            ),
            ScrollEntrance(
              type: ScrollEntranceType.slideUp,
              delayIndex: 3,
              child: _buildCustomFeatureCard(
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

  Widget _buildCustomFeatureCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
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

  Widget _buildFooter() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      children: [
        Divider(color: isLight ? AppColors.border : Colors.white10),
        const SizedBox(height: 24),
        AppBody(
          '© 2026 VIVAH Digital Wedding Invitation Workspace. Crafted with luxury design principles.',
          color: isLight ? AppColors.mutedText : Colors.white30,
          fontSize: 11,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// Helper classification function for hover cards
String _getCollectionForId(int id) {
  if ([1, 2, 4, 5, 6].contains(id)) return 'Royal';
  if ([7, 8, 9].contains(id)) return 'Luxury';
  if ([3, 10, 11, 12].contains(id)) return 'Floral';
  return 'Modern';
}

final hoverTemplateProvider = StateProvider.family<bool, int>((ref, id) => false);

// -------------------------------------------------------------
// PREMIUM OVERLAY HOVER CARD WIDGET
// -------------------------------------------------------------
class _ShowcaseHoverCard extends ConsumerWidget {
  final RemoteTemplateModel template;
  final Widget cardWidget;
  final VoidCallback onSelect;

  const _ShowcaseHoverCard({
    required this.template,
    required this.cardWidget,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final category = _getCollectionForId(template.id);
    final isHovered = ref.watch(hoverTemplateProvider(template.id));

    return MouseRegion(
      onEnter: (_) => ref.read(hoverTemplateProvider(template.id).notifier).state = true,
      onExit: (_) => ref.read(hoverTemplateProvider(template.id).notifier).state = false,
      child: AnimatedScale(
        scale: isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isLight 
                    ? Colors.black.withOpacity(isHovered ? 0.12 : 0.06) 
                    : Colors.black.withOpacity(isHovered ? 0.6 : 0.4),
                blurRadius: isHovered ? 16 : 8,
                offset: Offset(0, isHovered ? 8 : 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // The Actual Card Preview wrapped in RepaintBoundary to eliminate scroll repaint lag
              Positioned.fill(
                child: RepaintBoundary(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: 360,
                      height: 640,
                      child: cardWidget,
                    ),
                  ),
                ),
              ),

              // Animated Golden Border overlay highlight on hover
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isHovered 
                            ? (isLight ? AppColors.accentGold.withOpacity(0.8) : AppColors.navyAccent.withOpacity(0.8)) 
                            : Colors.transparent, 
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              ),

              // Photo support visual badge overlay in top corner
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accentGold.withOpacity(0.4), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.add_a_photo, color: AppColors.accentGold, size: 10),
                      SizedBox(width: 4),
                      Text(
                        'PHOTO SETUP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom gradient info overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.9),
                        Colors.black.withOpacity(0.65),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        category.toUpperCase() + ' COLLECTION',
                        color: AppColors.accentGold,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        preventTranslation: true,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        template.title,
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        isSerif: true,
                        preventTranslation: true,
                      ),
                      const SizedBox(height: 2),
                      AppBody(
                        template.description,
                        color: Colors.white70,
                        fontSize: 10,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        preventTranslation: true,
                      ),
                      AnimatedCrossFade(
                        firstChild: const SizedBox(height: 0),
                        secondChild: Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: AppButton(
                            label: 'Use This Theme',
                            onPressed: onSelect,
                            width: double.infinity,
                            height: 36,
                          ),
                        ),
                        crossFadeState: isHovered 
                            ? CrossFadeState.showSecond 
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 200),
                      ),
                    ],
                  ),
                ),
              ),
              
              if (!isHovered)
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onSelect,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
