import 'package:flutter/material.dart';
import '../template_shared.dart';
import '../template_ui_model.dart';
import '../painters/template_painters.dart';

class MaroonPeacockTemplate extends StatelessWidget {
  final TemplateUIModel uiModel;
  final bool isPreview;

  const MaroonPeacockTemplate({
    super.key,
    required this.uiModel,
    required this.isPreview,
  });

  // Compile-time constant styles and colors
  static const Color _accentGold = Color(0xFFD4AF37);
  static const Color _peacockTeal = Color(0xFF00ADB5);
  static const Color _tealLowOpacity = Color(0x6600ADB5); // 40% opacity Teal
  static const Color _goldSemiOpaque = Color(0x99D4AF37); // 60% opacity Gold
  static const Color _goldLowOpacity = Color(0x66D4AF37); // 40% opacity Gold

  static const TextStyle _weddingLabelStyle = TextStyle(
    fontSize: 10,
    letterSpacing: 3.0,
    fontWeight: FontWeight.bold,
    color: _peacockTeal,
  );

  static const TextStyle _andStyle = TextStyle(
    fontFamily: 'Serif',
    fontSize: 26,
    color: _accentGold,
  );

  static const TextStyle _coupleNameStyle = TextStyle(
    fontFamily: 'Serif',
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: _accentGold,
    letterSpacing: 1.0,
  );

  static const TextStyle _dateStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 1.5,
  );

  static const TextStyle _timeStyle = TextStyle(
    fontSize: 11,
    color: _peacockTeal,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle _venueLabelStyle = TextStyle(
    fontSize: 9,
    letterSpacing: 2.0,
    fontWeight: FontWeight.bold,
    color: _peacockTeal,
  );

  static const TextStyle _venueNameStyle = TextStyle(
    fontFamily: 'Serif',
    fontSize: 15,
    color: Color(0xFFF9F6F0),
    fontWeight: FontWeight.w600,
  );

  static const TextStyle _venueAddressStyle = TextStyle(
    fontSize: 11,
    color: Colors.white54,
    height: 1.4,
  );

  static const TextStyle _messageStyle = TextStyle(
    fontStyle: FontStyle.italic,
    fontSize: 11,
    color: Colors.white38,
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
          backgroundGradient: const [
            Color(0xFF380208), // Rich Royal Maroon
            Color(0xFF180004), // Dark Midnight Maroon
          ],
          child: Stack(
            children: [
              // Peacock Feather Accents (Painters)
              const Positioned(
                top: 20,
                right: -40,
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: CustomPaint(
                    painter: PeacockFeatherPainter(),
                  ),
                ),
              ),
              const Positioned(
                bottom: 20,
                left: -40,
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: CustomPaint(
                    painter: PeacockFeatherPainter(isRotated: true),
                  ),
                ),
              ),

              // Intricate Border Frame
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: _tealLowOpacity, width: 1), // Peacock Teal Accent
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: _goldSemiOpaque, width: 1.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 24),
                              // Peacock Crown Icon
                              const Icon(
                                Icons.eco_outlined,
                                color: _accentGold,
                                size: 32,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'WEDDING CELEBRATION',
                                style: _weddingLabelStyle,
                              ),
                              const SizedBox(height: 24),
                              // Names
                              Text(
                                uiModel.brideName,
                                style: _coupleNameStyle,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                '&',
                                style: _andStyle,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                uiModel.groomName,
                                style: _coupleNameStyle,
                                textAlign: TextAlign.center,
                              ),
                              CouplePhotosWidget(
                                invitation: uiModel.invitation,
                                accentColor: _accentGold,
                                collection: 'Royal',
                                isPreview: isPreview,
                              ),
                              const SizedBox(height: 20),
                              
                              // Date Panel
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: const BoxDecoration(
                                  border: Border.symmetric(
                                    horizontal: BorderSide(color: _goldLowOpacity, width: 1),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      uiModel.dateString.toUpperCase(),
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
                              const SizedBox(height: 28),
  
                              // Venue
                              const Text(
                                'EVENT VENUE',
                                style: _venueLabelStyle,
                              ),
                              const SizedBox(height: 8),
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
                              const SizedBox(height: 32),
  
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
