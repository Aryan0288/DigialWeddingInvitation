import 'package:flutter/material.dart';
import '../template_shared.dart';
import '../template_ui_model.dart';
import '../painters/template_painters.dart';

class RegalMaroonSideArchTemplate extends StatelessWidget {
  final TemplateUIModel uiModel;
  final bool isPreview;

  const RegalMaroonSideArchTemplate({
    super.key,
    required this.uiModel,
    required this.isPreview,
  });

  static const maroonColor = Color(0xFF600018);
  static const goldColor = Color(0xFFD4AF37);

  // Pre-cached static typography styles
  static final TextStyle _familyTitleStyle = TemplateFontCache.cormorantGaramond(
    textStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.bold,
      color: maroonColor,
      letterSpacing: 1.5,
    ),
  );

  static final TextStyle _inviteMsgStyle = TemplateFontCache.poppins(
    textStyle: const TextStyle(
      fontSize: 9,
      color: Color(0xFF6B645C),
      height: 1.4,
    ),
  );

  static final TextStyle _coupleNameStyle = TemplateFontCache.cormorantGaramond(
    textStyle: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: maroonColor,
      height: 1.1,
    ),
  );

  static final TextStyle _andStyle = TemplateFontCache.greatVibes(
    textStyle: const TextStyle(
      fontSize: 22,
      color: goldColor,
    ),
  );

  static final TextStyle _inviteStatementStyle = TemplateFontCache.poppins(
    textStyle: const TextStyle(
      fontSize: 8,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
      color: Color(0xCC600018), // 80% opacity maroon
    ),
  );

  static final TextStyle _dateStyle = TemplateFontCache.cormorantGaramond(
    textStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.bold,
      color: Color(0xFF2D2A26),
    ),
  );

  static final TextStyle _timeStyle = TemplateFontCache.poppins(
    textStyle: const TextStyle(
      fontSize: 10,
      color: Color(0xFF6B645C),
    ),
  );

  static final TextStyle _venueTitleStyle = TemplateFontCache.poppins(
    textStyle: const TextStyle(
      fontSize: 9,
      fontWeight: FontWeight.bold,
      color: Color(0xFF2D2A26),
    ),
  );

  static final TextStyle _venueAddressStyle = TemplateFontCache.poppins(
    textStyle: const TextStyle(
      fontSize: 8,
      color: Color(0xFF6B645C),
      height: 1.3,
    ),
  );

  static final TextStyle _rsvpStyle = TemplateFontCache.poppins(
    textStyle: const TextStyle(
      fontSize: 8,
      fontWeight: FontWeight.bold,
      color: Color(0xFF6B645C),
    ),
  );

  static final TextStyle _receptionStyle = TemplateFontCache.greatVibes(
    textStyle: const TextStyle(
      fontSize: 18,
      color: goldColor,
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
          backgroundColor: const Color(0xFFFAF7F2), // Elegant warm cream
          child: Stack(
            children: [
              // Wavy side panel on the right side
              const Positioned.fill(
                child: CustomPaint(
                  painter: WavySideArchPainter(
                    maroonColor: maroonColor,
                    goldColor: goldColor,
                  ),
                ),
              ),

              // Gold hanging ornaments/foliage on the top right maroon panel
              const Positioned(
                top: 20,
                right: 20,
                child: Opacity(
                  opacity: 0.25,
                  child: Icon(Icons.filter_vintage, color: goldColor, size: 40),
                ),
              ),
              const Positioned(
                bottom: 120,
                right: 30,
                child: Opacity(
                  opacity: 0.2,
                  child: Icon(Icons.spa, color: goldColor, size: 36),
                ),
              ),

              // Left-aligned Content
              Positioned(
                top: 40,
                left: 28,
                width: 220, // Keep content on the left cream side
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Family Line
                    Text(
                      uiModel.brideName == 'Bride' && uiModel.groomName == 'Groom'
                          ? 'THE SINGH & GUPTA FAMILIES'
                          : 'THE FAMILY INVITATION',
                      style: _familyTitleStyle,
                    ),
                    const SizedBox(height: 6),

                    // invite line
                    Text(
                      'cordially invite you to the wedding of their son & daughter',
                      style: _inviteMsgStyle,
                    ),
                    const SizedBox(height: 20),

                    // Bride Name
                    Text(
                      uiModel.brideName == 'Bride' ? 'Prerna Singh' : uiModel.brideName,
                      style: _coupleNameStyle,
                    ),
                    
                    // weds / &
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        '&',
                        style: _andStyle,
                      ),
                    ),

                    // Groom Name
                    Text(
                      uiModel.groomName == 'Groom' ? 'Sumit Gupta' : uiModel.groomName,
                      style: _coupleNameStyle,
                    ),
                    const SizedBox(height: 20),

                    // invitation statement
                    Text(
                      'ARE INVITING FOR THEIR WEDDING CEREMONY',
                      style: _inviteStatementStyle,
                    ),
                    const SizedBox(height: 14),

                    // Date & Time Grid
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, color: maroonColor, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            uiModel.dateStringShort,
                            style: _dateStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: maroonColor, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          uiModel.timeString,
                          style: _timeStyle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Venue Location
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, color: maroonColor, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                uiModel.venueName == 'The Grand Palace Resort'
                                    ? 'The Church Premise'
                                    : uiModel.venueName,
                                style: _venueTitleStyle,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                uiModel.venueAddress == 'Main Palace Road, New Delhi'
                                    ? 'Assemblies of God, Mariville Homes, Accra'
                                    : uiModel.venueAddress,
                                style: _venueAddressStyle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // RSVP
                    Text(
                      'RSVP: +233541576039, +233546378549',
                      style: _rsvpStyle,
                    ),
                    const SizedBox(height: 12),
                    
                    Text(
                      'Reception to Follow',
                      style: _receptionStyle,
                    ),
                  ],
                ),
              ),

              // Couple integration at bottom left
              Positioned(
                bottom: 24,
                left: 28,
                child: SizedBox(
                  width: 90,
                  height: 100,
                  child: CoupleFrameOrIllustrationWidget(
                    invitation: uiModel.invitation,
                    accentColor: maroonColor,
                    frameStyle: 'WavyMaroon',
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
