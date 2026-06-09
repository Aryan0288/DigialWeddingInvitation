import 'package:flutter/material.dart';
import '../template_shared.dart';
import '../template_ui_model.dart';
import '../painters/template_painters.dart';

class GoldRedMandalaTemplate extends StatelessWidget {
  final TemplateUIModel uiModel;
  final bool isPreview;

  const GoldRedMandalaTemplate({
    super.key,
    required this.uiModel,
    required this.isPreview,
  });

  // Compile-time constant styles and colors
  static const Color _accentGold = Color(0xFFD4AF37);
  static const Color _mandalaColor = Color(0x26D4AF37); // 15% opacity Gold
  static const Color _goldSemiOpaque = Color(0xCCD4AF37); // 80% opacity Gold
  static const Color _goldLowOpacity = Color(0x80D4AF37); // 50% opacity Gold

  static const TextStyle _shubhVivahStyle = TextStyle(
    fontFamily: 'Serif',
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: _accentGold,
    letterSpacing: 2.0,
  );

  static const TextStyle _invitationLabelStyle = TextStyle(
    fontSize: 10,
    letterSpacing: 4.0,
    fontWeight: FontWeight.bold,
    color: _goldSemiOpaque,
  );

  static const TextStyle _wedsStyle = TextStyle(
    fontFamily: 'Serif',
    fontStyle: FontStyle.italic,
    fontSize: 22,
    color: _accentGold,
  );

  static const TextStyle _coupleNameStyle = TextStyle(
    fontFamily: 'Serif',
    fontSize: 30,
    fontWeight: FontWeight.w300,
    color: Colors.white,
    letterSpacing: 1.5,
    shadows: [
      Shadow(
        blurRadius: 4.0,
        color: Colors.black45,
        offset: Offset(1.0, 1.0),
      ),
    ],
  );

  static const TextStyle _joinUsStyle = TextStyle(
    fontSize: 9,
    letterSpacing: 2.5,
    fontWeight: FontWeight.bold,
    color: _accentGold,
  );

  static const TextStyle _dateStyle = TextStyle(
    fontFamily: 'Serif',
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Color(0xFFF9F6F0),
    letterSpacing: 1.0,
  );

  static const TextStyle _timeStyle = TextStyle(
    fontSize: 12,
    color: Colors.white70,
  );

  static const TextStyle _venueTitleStyle = TextStyle(
    fontSize: 9,
    letterSpacing: 2.5,
    fontWeight: FontWeight.bold,
    color: _accentGold,
  );

  static const TextStyle _venueNameStyle = TextStyle(
    fontFamily: 'Serif',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle _venueAddressStyle = TextStyle(
    fontSize: 11,
    color: Colors.white60,
    height: 1.4,
  );

  static const TextStyle _messageStyle = TextStyle(
    fontStyle: FontStyle.italic,
    fontSize: 11,
    color: Colors.white54,
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
            Color(0xFF5B0000), // Deep Royal Red
            Color(0xFF8F0000), // Bright Crimson
            Color(0xFF3B0000), // Crimson Black
          ],
          child: Stack(
            children: [
              // Background Mandala Painters
              Positioned(
                top: -120,
                left: -120,
                right: -120,
                child: SizedBox(
                  height: 300,
                  child: CustomPaint(
                    painter: MandalaPainter(color: _mandalaColor),
                  ),
                ),
              ),
              Positioned(
                bottom: -150,
                left: -120,
                right: -120,
                child: SizedBox(
                  height: 300,
                  child: CustomPaint(
                    painter: MandalaPainter(color: _mandalaColor),
                  ),
                ),
              ),

              // Double Gold Border
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: _accentGold, width: 1.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: _goldLowOpacity, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 24),
                              // Golden Shubh Vivah Logo
                              const Text(
                                'शुभ विवाह',
                                style: _shubhVivahStyle,
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'INVITATION',
                                style: _invitationLabelStyle,
                              ),
                              const SizedBox(height: 16),
                              // Couple Names
                              Text(
                                uiModel.brideName,
                                style: _coupleNameStyle,
                                textAlign: TextAlign.center,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'weds',
                                  style: _wedsStyle,
                                ),
                              ),
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
                              
                              // Divider Line
                              Container(
                                width: 60,
                                height: 1.5,
                                color: _accentGold,
                              ),
                              const SizedBox(height: 28),
  
                              // Date
                              const Text(
                                'JOIN US ON',
                                style: _joinUsStyle,
                              ),
                              const SizedBox(height: 8),
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
                              const SizedBox(height: 24),
  
                              // Venue
                              const Text(
                                'VENUE',
                                style: _venueTitleStyle,
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
                              const SizedBox(height: 28),
  
                              // Personal Message
                              if (uiModel.personalMessage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 24.0),
                                  child: Text(
                                    '" ${uiModel.personalMessage} "',
                                    style: _messageStyle,
                                    textAlign: TextAlign.center,
                                  ),
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
