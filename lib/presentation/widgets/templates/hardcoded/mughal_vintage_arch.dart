import 'package:flutter/material.dart';
import '../template_shared.dart';
import '../template_ui_model.dart';
import '../painters/template_painters.dart';

class MughalVintageArchTemplate extends StatelessWidget {
  final TemplateUIModel uiModel;
  final bool isPreview;

  const MughalVintageArchTemplate({
    super.key,
    required this.uiModel,
    required this.isPreview,
  });

  static const _goldColor = Color(0xFFD4AF37);
  static const _maroonColor = Color(0xFF5B0000);
  static const _goldLowOpacity = Color(0x80D4AF37); // 50% opacity Gold

  // Pre-cached static typography styles
  static final TextStyle _familyTitleStyle = TemplateFontCache.cormorantGaramond(
    textStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Color(0xFF5B0000),
      letterSpacing: 2.0,
    ),
  );

  static final TextStyle _inviteMsgStyle = TemplateFontCache.greatVibes(
    textStyle: const TextStyle(
      fontSize: 15,
      color: Color(0xFF704A1B),
    ),
  );

  static final TextStyle _coupleNameStyle = TemplateFontCache.cormorantGaramond(
    textStyle: const TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      color: Color(0xFF5B0000),
      letterSpacing: 1.0,
    ),
  );

  static final TextStyle _wedsStyle = TemplateFontCache.greatVibes(
    textStyle: const TextStyle(
      fontSize: 18,
      color: _goldColor,
    ),
  );

  static final TextStyle _inviteCeremonyStyle = TemplateFontCache.poppins(
    textStyle: const TextStyle(
      fontSize: 8,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5,
      color: Color(0xFF704A1B),
    ),
  );

  static final TextStyle _dateBoxStyle = TemplateFontCache.cormorantGaramond(
    textStyle: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: Color(0xFF5B0000),
      letterSpacing: 0.5,
    ),
  );

  static final TextStyle _venueTitleStyle = TemplateFontCache.poppins(
    textStyle: const TextStyle(
      fontSize: 9,
      fontWeight: FontWeight.w600,
      color: Color(0xFF5B0000),
    ),
  );

  static final TextStyle _venueAddressStyle = TemplateFontCache.poppins(
    textStyle: const TextStyle(
      fontSize: 8,
      color: Color(0xFF704A1B),
    ),
  );

  static final TextStyle _rsvpHeaderStyle = TemplateFontCache.poppins(
    textStyle: const TextStyle(
      fontSize: 8,
      fontWeight: FontWeight.bold,
      color: Color(0xFF5B0000),
    ),
  );

  static final TextStyle _rsvpBodyStyle = TemplateFontCache.poppins(
    textStyle: const TextStyle(
      fontSize: 7,
      color: Color(0xFF704A1B),
      height: 1.3,
    ),
  );

  static final TextStyle _receptionStyle = TemplateFontCache.greatVibes(
    textStyle: const TextStyle(
      fontSize: 16,
      color: _goldColor,
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
          bgPatternAsset: AppAssetImages.design4,
          bgPatternOpacity: 0.20,
          backgroundGradient: const [
            Color(0xFFF5EFEB),
            Color(0xFFEADCC9),
          ],
          child: Stack(
            children: [
              // Custom Mughal Arch Frame (fills top and sides with Maroon, inside is vintage cream)
              const Positioned.fill(
                child: CustomPaint(
                  painter: MughalArchPainter(
                    archColor: _goldColor,
                    outerBgColor: _maroonColor,
                  ),
                ),
              ),

              // Hanging Lanterns
              const Positioned.fill(
                child: CustomPaint(
                  painter: MughalLanternsPainter(goldColor: _goldColor),
                ),
              ),

              // Content Layout
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(top: 130, left: 36, right: 36, bottom: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Family Title
                      Text(
                        uiModel.brideName == 'Bride' && uiModel.groomName == 'Groom'
                            ? 'THE SINGH & GUPTA FAMILIES'
                            : 'THE FAMILY OF BRIDE & GROOM',
                        style: _familyTitleStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      
                      // Invitation message line
                      Text(
                        'cordially invite you to the wedding of their son & daughter',
                        style: _inviteMsgStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),

                      // Bride Name
                      Text(
                        uiModel.brideName == 'Bride' ? 'Prerna Singh' : uiModel.brideName,
                        style: _coupleNameStyle,
                        textAlign: TextAlign.center,
                      ),
                      
                      // weds
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          'weds',
                          style: _wedsStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Groom Name
                      Text(
                        uiModel.groomName == 'Groom' ? 'Sumit Gupta' : uiModel.groomName,
                        style: _coupleNameStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      Text(
                        'ARE INVITING FOR THEIR WEDDING CEREMONY',
                        style: _inviteCeremonyStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // Date and Time Box
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: const BoxDecoration(
                          border: Border.symmetric(
                            horizontal: BorderSide(color: _goldLowOpacity, width: 1),
                          ),
                        ),
                        child: Text(
                          '${uiModel.dateString.toUpperCase()} | ${uiModel.timeString.toUpperCase()}',
                          style: _dateBoxStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Venue Title & Address
                      Text(
                        uiModel.venueName == 'The Grand Palace Resort'
                            ? 'AT THE CHURCH PREMISE, ACCRA'
                            : uiModel.venueName.toUpperCase(),
                        style: _venueTitleStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        uiModel.venueAddress == 'Main Palace Road, New Delhi'
                            ? 'Assemblies of God, Family Praise, Mariville Homes'
                            : uiModel.venueAddress,
                        style: _venueAddressStyle,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),

                      // RSVP & Bottom text row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'RSVP:',
                                style: _rsvpHeaderStyle,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '+233541576039\n+233546378549',
                                style: _rsvpBodyStyle,
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            'Reception to Follow',
                            style: _receptionStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Couple Integration in the Bottom-Right Corner
              Positioned(
                bottom: 20,
                right: 20,
                child: SizedBox(
                  width: 90,
                  height: 100,
                  child: CoupleFrameOrIllustrationWidget(
                    invitation: uiModel.invitation,
                    accentColor: _goldColor,
                    frameStyle: 'Mughal',
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
