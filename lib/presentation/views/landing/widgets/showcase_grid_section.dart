import 'package:flutter/material.dart';
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

// Helper classification function for hover cards
String _getCollectionForId(int id) {
  if ([1, 2, 4, 5, 6].contains(id)) return 'Royal';
  if ([7, 8, 9].contains(id)) return 'Luxury';
  if ([3, 10, 11, 12].contains(id)) return 'Floral';
  return 'Modern';
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
    // Desktop (>=1024): 5 columns
    final int gridColumns = width < 600 ? 2 : (width < 1024 ? 3 : 5);

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
// Uses explicit AnimationController — zero ticker cost when not hovered.
// Transform.scale uses GPU compositor layer for smooth hover animation.
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

class _ShowcaseHoverCardState extends State<ShowcaseHoverCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;
  bool _isHovered = false;

  // Static shadow — never changes, never causes re-rasterization
  static final List<BoxShadow> _cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.18),
      blurRadius: 10,
      offset: const Offset(0, 5),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onEnter() {
    if (!_isHovered) {
      _isHovered = true;
      _hoverController.forward();
    }
  }

  void _onExit() {
    if (_isHovered) {
      _isHovered = false;
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final category = _getCollectionForId(widget.template.id);

    return MouseRegion(
      onEnter: (_) => _onEnter(),
      onExit: (_) => _onExit(),
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _cardShadow,
          ),
          // Clip.hardEdge avoids the expensive saveLayer that Clip.antiAlias requires
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              // The cached card preview — no double FittedBox, template handles its own sizing
              Positioned.fill(
                child: RepaintBoundary(
                  child: widget.cardWidget,
                ),
              ),

              // Animated golden border overlay on hover
              AnimatedBuilder(
                animation: _hoverController,
                builder: (context, _) {
                  final borderColor = _opacityAnim.value > 0.01
                      ? (isLight
                          ? AppColors.accentGold.withOpacity(0.8 * _opacityAnim.value)
                          : AppColors.navyAccent.withOpacity(0.8 * _opacityAnim.value))
                      : Colors.transparent;
                  return IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: borderColor,
                          width: 2.0,
                        ),
                      ),
                    ),
                  );
                },
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
                child: Container(
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
                        widget.template.title,
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        isSerif: true,
                        preventTranslation: true,
                      ),
                      const SizedBox(height: 2),
                      AppBody(
                        widget.template.description,
                        color: Colors.white70,
                        fontSize: 10,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        preventTranslation: true,
                      ),
                      // Hover-revealed CTA button — only rendered when animation is active
                      AnimatedBuilder(
                        animation: _opacityAnim,
                        builder: (context, child) {
                          if (_opacityAnim.value < 0.01) return const SizedBox.shrink();
                          return Opacity(
                            opacity: _opacityAnim.value,
                            child: child,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: AppButton(
                            label: 'Use This Theme',
                            onPressed: widget.onSelect,
                            width: double.infinity,
                            height: 36,
                          ),
                        ),
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

