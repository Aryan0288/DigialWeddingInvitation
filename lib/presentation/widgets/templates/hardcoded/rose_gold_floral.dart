import 'package:flutter/material.dart';
import '../template_shared.dart';
import '../template_ui_model.dart';
import '../painters/template_painters.dart';

class RoseGoldFloralTemplate extends StatelessWidget {
  final TemplateUIModel uiModel;
  final bool isPreview;

  const RoseGoldFloralTemplate({
    super.key,
    required this.uiModel,
    required this.isPreview,
  });

  // Compile-time constant styles and colors
  static const Color _roseGold = Color(0xFFB76E79);
  static const Color _darkRose = Color(0xFF4A3437);
  static const Color _mediumRose = Color(0xFF7A5C61);
  static const Color _roseGoldSemiOpaque = Color(0x99B76E79); // 60% opacity Rose Gold
  static const Color _roseGoldLowOpacity = Color(0x80B76E79);  // 50% opacity Rose Gold

  static const TextStyle _saveDateStyle = TextStyle(
    fontSize: 9,
    letterSpacing: 2.0,
    fontWeight: FontWeight.w600,
    color: _roseGold,
  );

  static const TextStyle _andStyle = TextStyle(
    fontFamily: 'Serif',
    fontSize: 22,
    color: _roseGold,
  );

  static const TextStyle _coupleNameStyle = TextStyle(
    fontFamily: 'Serif',
    fontSize: 34,
    fontWeight: FontWeight.w300,
    color: _darkRose,
    letterSpacing: 1.0,
  );

  static const TextStyle _dateStyle = TextStyle(
    fontFamily: 'Serif',
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: _darkRose,
    letterSpacing: 0.5,
  );

  static const TextStyle _timeStyle = TextStyle(
    fontSize: 12,
    color: _mediumRose,
  );

  static const TextStyle _venueNameStyle = TextStyle(
    fontFamily: 'Serif',
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: _darkRose,
  );

  static const TextStyle _venueAddressStyle = TextStyle(
    fontSize: 11,
    color: _mediumRose,
    height: 1.4,
  );

  static const TextStyle _messageStyle = TextStyle(
    fontStyle: FontStyle.italic,
    fontSize: 11,
    color: Color(0xFF9E7E83),
    height: 1.4,
  );

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 360,
        height: 640,
        child: DesignBackground(
          bgPatternAsset: AppAssetImages.design3,
          bgPatternOpacity: 0.15,
          backgroundGradient: const [
            Color(0xFFFFF0F2), // Light Soft Rose Gold
            Color(0xFFEAD1D5), // Deep Elegant Rose
            Color(0xFFD8B2B7), // Rose Gold Shimmer
          ],
          child: Stack(
            children: [
              // Floral Frame Corners
              const Positioned(
                top: 10,
                left: 10,
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: CustomPaint(
                    painter: FloralCornerPainter(),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Transform.rotate(
                  angle: 3.141592653589793,
                  child: const SizedBox(
                    width: 100,
                    height: 100,
                    child: CustomPaint(
                      painter: FloralCornerPainter(),
                    ),
                  ),
                ),
              ),

              // Thin Minimalist Rose Gold Border
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: _roseGoldSemiOpaque, width: 1.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 24),
                          const Icon(
                            Icons.filter_vintage_outlined,
                            color: _roseGold,
                            size: 24,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'SAVE THE DATE FOR THE WEDDING OF',
                            style: _saveDateStyle,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
                          // Names
                          Text(
                            uiModel.brideName,
                            style: _coupleNameStyle,
                            textAlign: TextAlign.center,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.0),
                            child: Text(
                              '&',
                              style: _andStyle,
                            ),
                          ),
                          Text(
                            uiModel.groomName,
                            style: _coupleNameStyle,
                            textAlign: TextAlign.center,
                          ),
                          CouplePhotosWidget(
                            invitation: uiModel.invitation,
                            accentColor: _roseGold,
                            collection: 'Floral',
                            isPreview: isPreview,
                          ),
                          const SizedBox(height: 20),
  
                          // Date & Time
                          Text(
                            uiModel.dateString,
                            style: _dateStyle,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            uiModel.timeString,
                            style: _timeStyle,
                          ),
                          const SizedBox(height: 24),
  
                          // Divider
                          Container(
                            width: 40,
                            height: 1,
                            color: _roseGoldLowOpacity,
                          ),
                          const SizedBox(height: 24),
  
                          // Venue
                          Text(
                            uiModel.venueName,
                            style: _venueNameStyle,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            uiModel.venueAddress,
                            style: _venueAddressStyle,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
  
                          // Message
                          if (uiModel.personalMessage.isNotEmpty)
                            Text(
                              '" ${uiModel.personalMessage} "',
                              style: _messageStyle,
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
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
