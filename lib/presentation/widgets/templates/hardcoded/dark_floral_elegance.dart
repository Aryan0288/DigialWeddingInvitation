import 'package:flutter/material.dart';
import '../template_shared.dart';
import '../template_ui_model.dart';

class DarkFloralEleganceTemplate extends StatelessWidget {
  final TemplateUIModel uiModel;
  final bool isPreview;

  const DarkFloralEleganceTemplate({
    super.key,
    required this.uiModel,
    required this.isPreview,
  });

  static const goldColor = Color(0xFFD4AF37);
  static const whiteColor = Colors.white;
  static const creamColor = Color(0xFFF5EDD8);
  static const _goldSemiOpaque = Color(0x99D4AF37); // 60% opacity gold
  static const _goldLowOpacity = Color(0x80D4AF37);  // 50% opacity gold
  static const _creamSemiOpaque = Color(0xCCF5EDD8); // 80% opacity cream
  static const _creamLowOpacity = Color(0xB2F5EDD8);  // 70% opacity cream

  // Pre-cached static typography styles
  static final TextStyle _shubhVivahStyle = TemplateFontCache.poppins(
    textStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: goldColor,
      letterSpacing: 2.5,
    ),
  );

  static final TextStyle _inviteMsgStyle = TemplateFontCache.poppins(
    textStyle: const TextStyle(
      fontSize: 9,
      letterSpacing: 1.2,
      color: creamColor,
      fontStyle: FontStyle.italic,
    ),
  );

  static final TextStyle _coupleNameStyle = TemplateFontCache.cormorantGaramond(
    textStyle: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: whiteColor,
      letterSpacing: 1.2,
      height: 1.1,
    ),
  );

  static final TextStyle _wedsStyle = TemplateFontCache.greatVibes(
    textStyle: const TextStyle(
      fontSize: 22,
      color: goldColor,
    ),
  );

  static final TextStyle _dateTimeStyle = TemplateFontCache.poppins(
    textStyle: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: creamColor,
      letterSpacing: 0.5,
    ),
  );

  static final TextStyle _venueNameStyle = TemplateFontCache.cormorantGaramond(
    textStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: whiteColor,
      letterSpacing: 0.8,
    ),
  );

  static final TextStyle _venueAddressStyle = TemplateFontCache.poppins(
    textStyle: const TextStyle(
      fontSize: 9,
      color: _creamSemiOpaque,
      height: 1.3,
    ),
  );

  static final TextStyle _personalMessageStyle = TemplateFontCache.poppins(
    textStyle: const TextStyle(
      fontSize: 8.5,
      fontStyle: FontStyle.italic,
      color: _creamLowOpacity,
      height: 1.4,
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
          bgPatternAsset: AppAssetImages.cardDesign1,
          bgPatternOpacity: 1.0,
          child: Stack(
            children: [
              // --- Layer 2: Dynamic text overlays on the empty dark center zone ---
              Positioned(
                top: 108,
                left: 28,
                right: 28,
                bottom: 210,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Sanskrit header
                    Text(
                      'शुभ विवाह',
                      style: _shubhVivahStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),

                    // Thin gold divider
                    Container(
                      width: 120,
                      height: 1.0,
                      color: _goldSemiOpaque,
                    ),
                    const SizedBox(height: 14),

                    // Invite line
                    Text(
                      'Together with their families',
                      style: _inviteMsgStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Bride Name
                    Text(
                      uiModel.brideName == 'Bride' ? 'Prerna Singh' : uiModel.brideName,
                      style: _coupleNameStyle,
                    ),

                    // Weds in script
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
                    const SizedBox(height: 14),

                    // Thin gold divider
                    Container(
                      width: 100,
                      height: 1.0,
                      color: _goldLowOpacity,
                    ),
                    const SizedBox(height: 12),

                    // Date & Time row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            color: goldColor, size: 11),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            '${uiModel.dateStringShort}  •  ${uiModel.timeString}',
                            style: _dateTimeStyle,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Venue Name
                    Text(
                      uiModel.venueName == 'The Grand Palace Resort'
                          ? 'The Grand Palace Hall'
                          : uiModel.venueName,
                      style: _venueNameStyle,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Venue Address
                    Text(
                      uiModel.venueAddress == 'Main Palace Road, New Delhi'
                          ? 'Main Palace Road, New Delhi'
                          : uiModel.venueAddress,
                      style: _venueAddressStyle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Personal message
                    if (uiModel.personalMessage.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        '" ${uiModel.personalMessage} "',
                        style: _personalMessageStyle,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
