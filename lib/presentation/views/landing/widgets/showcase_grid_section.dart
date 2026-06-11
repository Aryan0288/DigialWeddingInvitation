import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/invitation_model.dart';
import '../../../../data/models/remote_template_model.dart';
import '../../../viewmodels/landing_viewmodel.dart';
import '../../../widgets/templates_widgets.dart';
import '../../../widgets/common/app_text.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/scroll_entrance.dart';

// O(1) Static Map for category lookups
const Map<int, String> _collectionCategoryMap = {
  1: 'Royal',
  2: 'Royal',
  4: 'Royal',
  5: 'Royal',
  6: 'Royal',
  7: 'Luxury',
  8: 'Luxury',
  9: 'Luxury',
  3: 'Floral',
  10: 'Floral',
  11: 'Floral',
  12: 'Floral',
};

String _getCollectionForId(int id) {
  return _collectionCategoryMap[id] ?? 'Modern';
}


// Stub invitation data for mockup previews
final _stubInvitation = InvitationModel(
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

final filteredTemplatesProvider = Provider.autoDispose<List<RemoteTemplateModel>>((ref) {
  final landingState = ref.watch(landingViewModelProvider);
  if (landingState.selectedCollection == 'All') return landingState.templates;
  return landingState.templates.where((t) {
    return _getCollectionForId(t.id) == landingState.selectedCollection;
  }).toList();
});

final cachedTemplateCardsProvider = Provider.autoDispose<Map<int, Widget>>((ref) {
  final allTemplates = ref.watch(landingViewModelProvider.select((s) => s.templates));
  final map = <int, Widget>{};
  for (final t in allTemplates) {
    final dummyInv = _stubInvitation.copyWith(selectedTemplateId: t.id);
    map[t.id] = RepaintBoundary(
      child: InvitationTemplateFactory.getTemplate(
        templateId: t.id,
        invitation: dummyInv,
        isPreview: true,
        availableTemplates: allTemplates,
      ),
    );
  }
  return map;
});

class ShowcaseGridSection extends ConsumerWidget {
  const ShowcaseGridSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadingTemplates = ref.watch(landingViewModelProvider.select((s) => s.loadingTemplates));

    if (loadingTemplates) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 60.0),
            child: CircularProgressIndicator(color: AppColors.navyAccent),
          ),
        ),
      );
    }
    
    final filteredTemplates = ref.watch(filteredTemplatesProvider);
    final cachedCards = ref.watch(cachedTemplateCardsProvider);
    final width = MediaQuery.of(context).size.width;
    
    // Grid Column configuration:
    // Mobile (<600): 2 columns for a compact, neat appearance
    // Tablet (<1024): 3 columns
    // Desktop (>=1024): 4 columns (for larger, more readable cards)
    final int gridColumns = width < 600 ? 2 : (width < 1024 ? 3 : 4);

    // Dynamic padding to center the grid with a max width of 1250px on desktop
    final double horizontalPadding;
    if (width >= 1250 + 48) {
      horizontalPadding = (width - 1250) / 2;
    } else {
      horizontalPadding = width < 600 ? 16.0 : 24.0;
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridColumns,
          crossAxisSpacing: width < 600 ? 24 : (width < 1024 ? 36 : 50), // Increased horizontal spacing
          mainAxisSpacing: width < 600 ? 32 : (width < 1024 ? 48 : 64), // Spacious vertical spacing
          childAspectRatio: 0.58,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final t = filteredTemplates[index];

            return ScrollEntrance(
              type: ScrollEntranceType.slideUp,
              delayIndex: 0,
              child: ShowcaseHoverCard(
                template: t,
                cardWidget: cachedCards[t.id] ?? const SizedBox(),
                onSelect: () => context.go('/builder?template=${t.id}'),
              ),
            );
          },
          childCount: filteredTemplates.length,
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// PREMIUM OVERLAY HOVER CARD WIDGET (Performance-optimized)
// Uses implicit animations (AnimatedScale / AnimatedOpacity / AnimatedContainer)
// — no per-card AnimationController, so zero ticker cost outside the 200ms
// hover transition. Scale uses a GPU compositor layer for smooth hover.
// -------------------------------------------------------------
class ShowcaseHoverCard extends StatefulWidget {
  final RemoteTemplateModel template;
  final Widget cardWidget;
  final VoidCallback onSelect;

  const ShowcaseHoverCard({
    super.key,
    required this.template,
    required this.cardWidget,
    required this.onSelect,
  });

  @override
  State<ShowcaseHoverCard> createState() => _ShowcaseHoverCardState();
}

class _ShowcaseHoverCardState extends State<ShowcaseHoverCard> {
  bool _isHovered = false;

  static const Duration _hoverDuration = Duration(milliseconds: 200);

  // Static final & compile-time constants (Strategy B & Const Optimization)
  static final List<BoxShadow> _cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.18),
      blurRadius: 10,
      offset: const Offset(0, 5),
    ),
  ];

  static final BoxDecoration _cardDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    boxShadow: _cardShadow,
  );

  static const BorderRadius _cardRadius =
      BorderRadius.all(Radius.circular(16));

  static final TextStyle _poppinsTextStyle = GoogleFonts.poppins();

  static final LinearGradient _bottomOverlayGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Colors.black.withOpacity(0.9),
      Colors.black.withOpacity(0.65),
      Colors.transparent,
    ],
  );

  static final BoxDecoration _badgeDecoration = BoxDecoration(
    color: const Color(0xA6000000), // 65% opacity Black
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: const Color(0x66D4AF37), width: 1), // 40% opacity Gold
  );

  // Precomputed transparent border (no glow) reused every build.
  static const Border _noBorder = Border.fromBorderSide(
    BorderSide(color: Colors.transparent, width: 2.0),
  );

  late String _preFormattedCategory;

  @override
  void initState() {
    super.initState();
    _preFormattedCategory = _formatCategory(widget.template.id);
  }

  @override
  void didUpdateWidget(covariant ShowcaseHoverCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.template.id != oldWidget.template.id) {
      _preFormattedCategory = _formatCategory(widget.template.id);
    }
  }

  static String _formatCategory(int id) =>
      '${_getCollectionForId(id).toUpperCase()} COLLECTION';

  void _onEnter() {
    if (!_isHovered) setState(() => _isHovered = true);
  }

  void _onExit() {
    if (_isHovered) setState(() => _isHovered = false);
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth < 1024;

    final Border hoverBorder = _isHovered
        ? Border.all(
            color: isLight
                ? AppColors.accentGold.withOpacity(0.8)
                : AppColors.navyAccent.withOpacity(0.8),
            width: 2.0,
          )
        : _noBorder;

    return MouseRegion(
      onEnter: (_) => _onEnter(),
      onExit: (_) => _onExit(),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: _hoverDuration,
        curve: Curves.easeOut,
        child: Container(
          decoration: _cardDecoration,
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              Positioned.fill(
                child: RepaintBoundary(
                  child: widget.cardWidget,
                ),
              ),

              // Animated golden border overlay on hover
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedContainer(
                    duration: _hoverDuration,
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      borderRadius: _cardRadius,
                      border: hoverBorder,
                    ),
                  ),
                ),
              ),

              // Photo support visual badge overlay in top corner
              Positioned(
                top: isMobile ? 6 : 12,
                right: isMobile ? 6 : 12,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 5 : 8,
                    vertical: isMobile ? 2 : 4,
                  ),
                  decoration: _badgeDecoration,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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

              // Bottom gradient info overlay (Adaptive to Light/Dark Mode)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 10 : 16,
                    vertical: isMobile ? 10 : 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: _bottomOverlayGradient,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        _preFormattedCategory,
                        color: AppColors.accentGold,
                        fontSize: isMobile ? 7 : 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: isMobile ? 1.0 : 1.5,
                        preventTranslation: true,
                        style: _poppinsTextStyle,
                      ),
                      SizedBox(height: isMobile ? 2 : 4),
                      AppText(
                        widget.template.title,
                        color: Colors.white,
                        fontSize: isMobile ? 12 : (isTablet ? 15 : 17),
                        fontWeight: FontWeight.bold,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        preventTranslation: true,
                        style: _poppinsTextStyle,
                      ),
                      if (!isMobile) ...[
                        const SizedBox(height: 4),
                        AppText(
                          widget.template.description,
                          color: Colors.white70,
                          fontSize: 11,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          preventTranslation: true,
                          style: _poppinsTextStyle,
                        ),
                      ],
                      // Hover-revealed CTA button
                      AnimatedSize(
                        duration: _hoverDuration,
                        curve: Curves.easeOut,
                        alignment: Alignment.topCenter,
                        child: _isHovered
                            ? Padding(
                                padding:
                                    EdgeInsets.only(top: isMobile ? 6.0 : 12.0),
                                child: AppButton(
                                  label: isMobile ? 'Select' : 'Use This Theme',
                                  onPressed: widget.onSelect,
                                  width: double.infinity,
                                  height: isMobile ? 28 : 36,
                                ),
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                    ],
                  ),
                ),
              ),

              // Tap surface for non-hovered state
              if (!_isHovered)
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onSelect,
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

