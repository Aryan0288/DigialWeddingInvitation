import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'template_shared.dart';
import 'template_ui_model.dart';
import 'painters/template_painters.dart';

class DynamicTemplateWidget extends StatelessWidget {
  final TemplateUIModel uiModel;
  final bool isPreview;

  const DynamicTemplateWidget({
    super.key,
    required this.uiModel,
    this.isPreview = true,
  });

  // Fully static — does not depend on uiModel, so allocate once.
  static final BoxDecoration _innerGlowDecoration = BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.15),
        blurRadius: 30,
        spreadRadius: -20,
        offset: const Offset(0, 0),
      ),
    ],
  );

  static const TextStyle _shubhVivahStyle = TextStyle(
    fontFamily: 'Serif',
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Color(0xFFD4AF37),
    letterSpacing: 2.0,
  );

  static const EdgeInsets _framePadding = EdgeInsets.all(16.0);
  static const EdgeInsets _innerFramePadding = EdgeInsets.all(4.0);
  static const EdgeInsets _contentPadding =
      EdgeInsets.symmetric(horizontal: 20.0);
  static const EdgeInsets _noFramePadding =
      EdgeInsets.symmetric(horizontal: 36.0, vertical: 32.0);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 360,
        height: 640,
        child: DesignBackground(
          bgPatternAsset: uiModel.bgPatternAsset,
          bgPatternOpacity: uiModel.bgPatternOpacity,
          backgroundGradient: uiModel.gradientColors.isNotEmpty 
              ? uiModel.gradientColors 
              : [uiModel.primaryColor, uiModel.primaryColor.withValues(alpha: 0.8)],
          child: Stack(
            children: [
              // Load dynamic network background pattern with safe fallback
              if (uiModel.hasBgPatternUrl && !uiModel.skipBgPatternIdCheck)
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: uiModel.bgPatternUrl,
                    fit: BoxFit.cover,
                    color: uiModel.bgPatternBlendColor,
                    colorBlendMode: BlendMode.dstIn,
                    // Decode at ~2x the 360x640 card size instead of the full
                    // ~2000px source — drastically lower memory & decode cost.
                    memCacheWidth: 720,
                    memCacheHeight: 1280,
                    placeholder: (context, url) => const SizedBox.shrink(),
                    errorWidget: (context, url, error) => const SizedBox.shrink(),
                  ),
                ),

              // Subtle overall inner glow
              Positioned.fill(
                child: Container(
                  decoration: _innerGlowDecoration,
                ),
              ),

              // Elegant thin double border frame
              if (!uiModel.hideFrame)
                Positioned.fill(
                  child: Padding(
                    padding: _framePadding,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: uiModel.secondaryColorSemiOpaque, width: 1.5),
                      ),
                      child: Padding(
                        padding: _innerFramePadding,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: uiModel.secondaryColorLowOpacity, width: 1),
                          ),
                          child: Stack(
                            children: [
                              // Render vintage luxury gold corners inside the borders
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: GoldCornerPainter(color: uiModel.secondaryColorCornerPaint),
                                ),
                              ),
                              
                              Positioned.fill(
                                child: Padding(
                                  padding: _contentPadding,
                                  child: _buildStructuralLayout(
                                    uiModel: uiModel,
                                    isPreview: isPreview,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                // Template 15 has no frame
                Positioned.fill(
                  child: Padding(
                    padding: _noFramePadding,
                    child: _buildStructuralLayout(
                      uiModel: uiModel,
                      isPreview: isPreview,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStructuralLayout({
    required TemplateUIModel uiModel,
    required bool isPreview,
  }) {
    switch (uiModel.collection) {
      case 'Royal':
        return _buildRoyalLayout(uiModel, isPreview: isPreview);
      case 'Luxury':
        return _buildLuxuryLayout(uiModel, isPreview: isPreview);
      case 'Floral':
        return _buildFloralLayout(uiModel, isPreview: isPreview);
      case 'Modern':
      default:
        return _buildModernLayout(uiModel, isPreview: isPreview);
    }
  }

  // ROYAL LAYOUT (Centered, Traditional Arches/Mandalas, Sanskrit sub-header)
  Widget _buildRoyalLayout(TemplateUIModel uiModel, {required bool isPreview}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        const Text('शुभ विवाह', style: _shubhVivahStyle),
        const SizedBox(height: 12),
        Text('SHUBH VIVAH INVITATION', style: uiModel.bodyLabelStyle),
        
        CouplePhotosWidget(
          invitation: uiModel.invitation,
          accentColor: uiModel.secondaryColor,
          collection: 'Royal',
          isPreview: isPreview,
        ),
        
        Text(uiModel.brideName, style: uiModel.titleStyle, textAlign: TextAlign.center),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text('weds', style: TextStyle(fontFamily: 'Serif', fontStyle: FontStyle.italic, fontSize: 18, color: uiModel.secondaryColor)),
        ),
        Text(uiModel.groomName, style: uiModel.titleStyle, textAlign: TextAlign.center),
        const SizedBox(height: 16),

        Container(width: 50, height: 1.5, color: uiModel.secondaryColor),
        const SizedBox(height: 16),

        Text('JOIN US ON', style: uiModel.bodyLabelStyle),
        const SizedBox(height: 6),
        Text(
          uiModel.dateString.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: uiModel.isDarkAccent ? uiModel.secondaryColor : const Color(0xFFF9F6F0),
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        Text(uiModel.timeString, style: TextStyle(fontSize: 11, color: uiModel.isDarkAccent ? uiModel.secondaryColorSemiOpaque : Colors.white70)),
        const SizedBox(height: 16),

        Text('VENUE', style: uiModel.bodyLabelStyle),
        const SizedBox(height: 4),
        Text(
          uiModel.venueName,
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: uiModel.isDarkAccent ? uiModel.secondaryColor : const Color(0xFFF9F6F0),
          ),
          textAlign: TextAlign.center,
        ),
        Text(uiModel.venueAddress, style: uiModel.textContentStyle, textAlign: TextAlign.center),
        const SizedBox(height: 12),

        if (uiModel.personalMessage.isNotEmpty)
          Text('" ${uiModel.personalMessage} "', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 10, color: uiModel.isDarkAccent ? uiModel.secondaryColor.withValues(alpha: 0.7) : Colors.white54, height: 1.3), textAlign: TextAlign.center),
      ],
    );
  }

  // LUXURY LAYOUT (Minimalist Asymmetric borders, fine-art margins, high fashion serif)
  Widget _buildLuxuryLayout(TemplateUIModel uiModel, {required bool isPreview}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('MEMORABLE CELEBRATION', style: uiModel.bodyLabelStyle.copyWith(fontSize: 8)),
            Icon(Icons.spa_outlined, color: uiModel.secondaryColor, size: 16),
          ],
        ),
        const SizedBox(height: 20),
        
        Text(uiModel.brideName.toUpperCase(), style: uiModel.titleStyle.copyWith(fontSize: 26, fontWeight: FontWeight.w600, letterSpacing: 2.0)),
        Text('AND', style: uiModel.bodyLabelStyle.copyWith(fontSize: 9, letterSpacing: 4.0)),
        Text(uiModel.groomName.toUpperCase(), style: uiModel.titleStyle.copyWith(fontSize: 26, fontWeight: FontWeight.w600, letterSpacing: 2.0)),
        
        CouplePhotosWidget(
          invitation: uiModel.invitation,
          accentColor: uiModel.secondaryColor,
          collection: 'Luxury',
          isPreview: isPreview,
        ),
        
        const SizedBox(height: 12),
        Container(height: 1, color: uiModel.secondaryColor.withValues(alpha: 0.3)),
        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WHEN', style: uiModel.bodyLabelStyle),
                  const SizedBox(height: 4),
                  Text(uiModel.dateString, style: uiModel.textContentStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 11)),
                  Text(uiModel.timeString, style: uiModel.textContentStyle.copyWith(fontSize: 10)),
                ],
              ),
            ),
            Container(width: 1, height: 40, color: uiModel.secondaryColor.withValues(alpha: 0.3)),
            const SizedBox(width: 16),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WHERE', style: uiModel.bodyLabelStyle),
                  const SizedBox(height: 4),
                  Text(uiModel.venueName, style: uiModel.textContentStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(uiModel.venueAddress, style: uiModel.textContentStyle.copyWith(fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (uiModel.personalMessage.isNotEmpty)
          Text('" ${uiModel.personalMessage} "', style: uiModel.textContentStyle.copyWith(fontStyle: FontStyle.italic, fontSize: 9.5, height: 1.3)),
      ],
    );
  }

  // FLORAL LAYOUT (Water-color feel, script typography, circular leaf-borders)
  Widget _buildFloralLayout(TemplateUIModel uiModel, {required bool isPreview}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Icon(Icons.filter_vintage_outlined, color: uiModel.secondaryColor, size: 28),
        const SizedBox(height: 8),
        Text('SAVE THE DATE', style: uiModel.bodyLabelStyle.copyWith(fontSize: 8, letterSpacing: 2.0)),
        const SizedBox(height: 12),

        Text(uiModel.brideName, style: uiModel.titleStyle.copyWith(fontSize: 34, fontStyle: FontStyle.italic)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text('&', style: TextStyle(fontSize: 20, color: uiModel.secondaryColor, fontStyle: FontStyle.italic)),
        ),
        Text(uiModel.groomName, style: uiModel.titleStyle.copyWith(fontSize: 34, fontStyle: FontStyle.italic)),
        
        CouplePhotosWidget(
          invitation: uiModel.invitation,
          accentColor: uiModel.secondaryColor,
          collection: 'Floral',
          isPreview: isPreview,
        ),
        
        const SizedBox(height: 8),
        Container(width: 40, height: 1.5, color: uiModel.secondaryColor.withValues(alpha: 0.5)),
        const SizedBox(height: 16),

        Text(uiModel.dateString, style: uiModel.titleStyle.copyWith(fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        Text(uiModel.timeString, style: uiModel.textContentStyle.copyWith(fontSize: 11), textAlign: TextAlign.center),
        const SizedBox(height: 16),

        Text(uiModel.venueName, style: uiModel.titleStyle.copyWith(fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        Text(uiModel.venueAddress, style: uiModel.textContentStyle.copyWith(fontSize: 11), textAlign: TextAlign.center),
        const SizedBox(height: 12),

        if (uiModel.personalMessage.isNotEmpty)
          Text('" ${uiModel.personalMessage} "', style: uiModel.textContentStyle.copyWith(fontStyle: FontStyle.italic, fontSize: 10), textAlign: TextAlign.center),
      ],
    );
  }

  // MODERN LAYOUT (Bold sans-serif headlines, structured grids, clean dividers)
  Widget _buildModernLayout(TemplateUIModel uiModel, {required bool isPreview}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: uiModel.secondaryColor, width: 1.0),
          ),
          child: Text('THE WEDDING INVITATION', style: uiModel.bodyLabelStyle.copyWith(fontSize: 8, letterSpacing: 1.5)),
        ),
        const SizedBox(height: 24),

        Text(uiModel.brideName.toUpperCase(), style: uiModel.titleStyle.copyWith(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text('+ JOINING HEARTS WITH +', style: uiModel.bodyLabelStyle.copyWith(fontSize: 8, color: uiModel.secondaryColor.withValues(alpha: 0.6))),
        ),
        Text(uiModel.groomName.toUpperCase(), style: uiModel.titleStyle.copyWith(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
        
        CouplePhotosWidget(
          invitation: uiModel.invitation,
          accentColor: uiModel.secondaryColor,
          collection: 'Modern',
          isPreview: isPreview,
        ),
        
        const SizedBox(height: 16),
        Container(width: double.infinity, height: 1.5, color: uiModel.secondaryColor),
        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TIMELINE', style: uiModel.bodyLabelStyle.copyWith(fontSize: 8)),
                  const SizedBox(height: 4),
                  Text(uiModel.dateString, style: uiModel.textContentStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 10.5)),
                  Text(uiModel.timeString, style: uiModel.textContentStyle.copyWith(fontSize: 9.5)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LOCATION', style: uiModel.bodyLabelStyle.copyWith(fontSize: 8)),
                  const SizedBox(height: 4),
                  Text(uiModel.venueName, style: uiModel.textContentStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 10.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(uiModel.venueAddress, style: uiModel.textContentStyle.copyWith(fontSize: 9.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (uiModel.personalMessage.isNotEmpty)
          Text('" ${uiModel.personalMessage} "', style: uiModel.textContentStyle.copyWith(fontStyle: FontStyle.italic, fontSize: 9.5, height: 1.3)),
      ],
    );
  }
}
