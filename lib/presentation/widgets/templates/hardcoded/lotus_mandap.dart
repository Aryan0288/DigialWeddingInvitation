import 'package:flutter/material.dart';
import '../template_shared.dart';
import '../template_ui_model.dart';
import '../painters/template_painters.dart';

class LotusMandapSaveTheDateTemplate extends StatelessWidget {
  final TemplateUIModel uiModel;
  final bool isPreview;

  const LotusMandapSaveTheDateTemplate({
    super.key,
    required this.uiModel,
    required this.isPreview,
  });

  static const _mandapColor = Color(0xFFD47F74);
  static const _goldLowOpacity = Color(0x99D4AF37); // 60% opacity Gold
  static const _peachWashHigh = Color(0x59FDD5CD);  // 35% opacity Peach
  static const _peachWashLow = Color(0x40FDD5CD);   // 25% opacity Peach

  // Pre-cached static typography styles
  static final TextStyle _headingStyle = TemplateFontCache.greatVibes(
    textStyle: const TextStyle(
      fontSize: 42,
      color: _mandapColor,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          color: Colors.white,
          offset: Offset(1, 1),
          blurRadius: 2,
        ),
      ],
    ),
  );

  static final TextStyle _celebrateStyle = TemplateFontCache.poppins(
    textStyle: const TextStyle(
      fontSize: 8,
      letterSpacing: 2.0,
      fontWeight: FontWeight.bold,
      color: Color(0xFF6B645C),
    ),
  );

  static final TextStyle _coupleNameStyle = TemplateFontCache.greatVibes(
    textStyle: const TextStyle(
      fontSize: 34,
      color: Color(0xFFE07A5F),
      fontWeight: FontWeight.w500,
    ),
  );

  static final TextStyle _dateStyle = TemplateFontCache.cormorantGaramond(
    textStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Color(0xFF2D2A26),
      letterSpacing: 1.0,
    ),
  );

  static final TextStyle _timeStyle = TemplateFontCache.poppins(
    textStyle: const TextStyle(
      fontSize: 10,
      color: Color(0xFF6B645C),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 360,
        height: 640,
        child: DesignBackground(
          bgPatternAsset: AppAssetImages.design2,
          bgPatternOpacity: 0.20,
          backgroundGradient: const [
            Color(0xFFFFF6F4),
            Color(0xFFFFECE7),
          ],
          child: Stack(
            children: [
              // Watercolor peach wash containers (SaaS dynamic paint simulation)
              Positioned(
                top: -60,
                left: 20,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _peachWashHigh,
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: -40,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _peachWashLow,
                  ),
                ),
              ),

              // Thin gold outer border around the card
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _goldLowOpacity,
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ),

              // Floating watercolor leaves/petals in background (soft decorations)
              const Positioned(
                top: 40,
                left: 24,
                child: Icon(Icons.spa_outlined, color: _mandapColor, size: 28),
              ),
              const Positioned(
                top: 80,
                right: 32,
                child: Icon(Icons.spa_outlined, color: _mandapColor, size: 22),
              ),

              // Palace Dome Mandap structure at bottom center
              const Positioned.fill(
                child: CustomPaint(
                  painter: PalaceMandapPainter(color: _mandapColor),
                ),
              ),

              // Lotus Flowers flanking column bases at the bottom
              const Positioned.fill(
                child: CustomPaint(
                  painter: LotusFlowerPainter(lotusColor: Color(0xFFF48FB1)),
                ),
              ),

              // Content Layout (positioned at the top)
              Positioned(
                top: 36,
                left: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Save the Date Heading
                    Text(
                      'Save the Date',
                      style: _headingStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // To celebrate the wedding of
                    Text(
                      'TO CELEBRATE THE WEDDING OF',
                      style: _celebrateStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),

                    // Couple Names
                    Text(
                      uiModel.brideName == 'Bride' && uiModel.groomName == 'Groom'
                          ? 'Lokesh & Priya'
                          : '${uiModel.brideName} & ${uiModel.groomName}',
                      style: _coupleNameStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Date
                    Text(
                      uiModel.dateStringShort.toUpperCase(),
                      style: _dateStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      uiModel.timeString,
                      style: _timeStyle,
                    ),
                  ],
                ),
              ),

              // Couple Integration under the Mandap Arch
              Positioned(
                bottom: 40,
                left: 80,
                right: 80,
                child: SizedBox(
                  height: 140,
                  child: CoupleFrameOrIllustrationWidget(
                    invitation: uiModel.invitation,
                    accentColor: _mandapColor,
                    frameStyle: 'LotusMandap',
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
}
