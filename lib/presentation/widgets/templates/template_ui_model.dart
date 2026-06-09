import 'package:flutter/material.dart';
import '../../../data/models/invitation_model.dart';
import '../../../data/models/remote_template_model.dart';
import 'template_shared.dart';

class TemplateUIModel {
  final InvitationModel invitation;
  final int templateId;
  final String brideName;
  final String groomName;
  final String dateString;
  final String dateStringShort;
  final String timeString;
  final String venueName;
  final String venueAddress;
  final String personalMessage;
  final String collection;

  // Visual Styling Properties
  final Color primaryColor;
  final Color secondaryColor;
  final List<Color> gradientColors;
  final bool isDarkAccent;
  final String? bgPatternAsset;
  final double bgPatternOpacity;
  final String bgPatternUrl;
  final bool hasBgPatternUrl;
  final bool skipBgPatternIdCheck;
  final bool hideFrame;

  // Cached Colors with Opacity (so we don't call withValues/withOpacity in build)
  final Color secondaryColorSemiOpaque; // 0.8 alpha
  final Color secondaryColorLowOpacity;  // 0.4 alpha
  final Color secondaryColorCornerPaint; // 0.7 alpha
  final Color bgPatternBlendColor;       // 0.06 alpha

  // Pre-cached text styles
  final TextStyle titleStyle;
  final TextStyle bodyLabelStyle;
  final TextStyle textContentStyle;

  TemplateUIModel({
    required this.invitation,
    required this.templateId,
    required this.brideName,
    required this.groomName,
    required this.dateString,
    required this.dateStringShort,
    required this.timeString,
    required this.venueName,
    required this.venueAddress,
    required this.personalMessage,
    required this.collection,
    required this.primaryColor,
    required this.secondaryColor,
    required this.gradientColors,
    required this.isDarkAccent,
    required this.bgPatternAsset,
    required this.bgPatternOpacity,
    required this.bgPatternUrl,
    required this.hasBgPatternUrl,
    required this.skipBgPatternIdCheck,
    required this.hideFrame,
    required this.secondaryColorSemiOpaque,
    required this.secondaryColorLowOpacity,
    required this.secondaryColorCornerPaint,
    required this.bgPatternBlendColor,
    required this.titleStyle,
    required this.bodyLabelStyle,
    required this.textContentStyle,
  });

  factory TemplateUIModel.build(
    InvitationModel invitation,
    int templateId,
    List<RemoteTemplateModel> availableTemplates,
  ) {
    // 1. Resolve names with fallback stubs
    final String bName = invitation.brideName.isEmpty ? 'Bride' : invitation.brideName;
    final String gName = invitation.groomName.isEmpty ? 'Groom' : invitation.groomName;
    final bool useStub = invitation.brideName.isEmpty && invitation.groomName.isEmpty;

    // 2. Resolve formatted date strings once
    final String dateString = formatWeddingDateLong(invitation.weddingDate, useStub: useStub);
    final String dateStringShort = formatWeddingDateShort(invitation.weddingDate, useStub: useStub);

    // 3. Resolve template specification
    RemoteTemplateModel? spec;
    if (templateId > 7 && availableTemplates.isNotEmpty) {
      spec = availableTemplates.firstWhere(
        (t) => t.id == templateId,
        orElse: () => availableTemplates.first,
      );
    }

    // 4. Resolve primary & secondary colors
    Color primaryColor;
    Color secondaryColor;
    List<Color> gradientColors = [];

    if (spec != null) {
      primaryColor = HexColor.fromHex(spec.primaryColorHex);
      secondaryColor = HexColor.fromHex(spec.secondaryColorHex);
      gradientColors = spec.bgGradientHex.map((hex) => HexColor.fromHex(hex)).toList();
    } else {
      // Hardcoded template color fallbacks based on ID
      switch (templateId) {
        case 1: // GoldRedMandalaTemplate
          primaryColor = const Color(0xFF5B0000);
          secondaryColor = const Color(0xFFD4AF37);
          gradientColors = const [
            Color(0xFF5B0000), // Deep Royal Red
            Color(0xFF8F0000), // Bright Crimson
            Color(0xFF3B0000), // Crimson Black
          ];
          break;
        case 2: // MaroonPeacockTemplate
          primaryColor = const Color(0xFF4A0E17);
          secondaryColor = const Color(0xFFD4AF37);
          gradientColors = const [
            Color(0xFF4A0E17), // Royal Maroon
            Color(0xFF7A1521), // Crimson Burgundy
            Color(0xFF2B050B), // Near Black
          ];
          break;
        case 3: // RoseGoldFloralTemplate
          primaryColor = const Color(0xFFFFF0F2);
          secondaryColor = const Color(0xFFB37E86);
          gradientColors = const [
            Color(0xFFFFF5F6),
            Color(0xFFFFE3E6),
          ];
          break;
        case 4: // MughalVintageArchTemplate
          primaryColor = const Color(0xFF1E3A2F);
          secondaryColor = const Color(0xFFC5A059);
          gradientColors = const [
            Color(0xFF162E25), // Mughal Forest Green
            Color(0xFF2C5E48), // Royal Emerald
            Color(0xFF0F1E18), // Deep Green Black
          ];
          break;
        case 5: // LotusMandapSaveTheDateTemplate
          primaryColor = const Color(0xFFFFF7F2);
          secondaryColor = const Color(0xFFC88D6D);
          gradientColors = const [
            Color(0xFFFFF9F5),
            Color(0xFFFBECE2),
          ];
          break;
        case 6: // RegalMaroonSideArchTemplate
          primaryColor = const Color(0xFF3B060D);
          secondaryColor = const Color(0xFFE8C88A);
          gradientColors = const [
            Color(0xFF3B060D),
            Color(0xFF5E0F19),
            Color(0xFF1F0104),
          ];
          break;
        case 7: // DarkFloralEleganceTemplate
          primaryColor = const Color(0xFF121212);
          secondaryColor = const Color(0xFFE5D5C5);
          gradientColors = const [
            Color(0xFF121212),
            Color(0xFF282828),
            Color(0xFF0A0A0A),
          ];
          break;
        default:
          primaryColor = const Color(0xFF5B0000);
          secondaryColor = const Color(0xFFD4AF37);
          gradientColors = const [
            Color(0xFF5B0000),
            Color(0xFF8F0000),
            Color(0xFF3B0000),
          ];
      }
    }

    final bool isDarkAccent = secondaryColor.computeLuminance() < 0.3;

    // 5. Precompute background asset pattern switches
    String? bgPatternAsset;
    double bgPatternOpacity = 0.05;

    switch (templateId) {
      case 8: // Ivory Gold
        bgPatternAsset = AppAssetImages.design7;
        bgPatternOpacity = 0.90;
        break;
      case 9: // Champagne Luxury
        bgPatternAsset = AppAssetImages.design2;
        bgPatternOpacity = 0.90;
        break;
      case 10: // Midnight Navy & Gold
        bgPatternAsset = AppAssetImages.design9;
        bgPatternOpacity = 0.95;
        break;
      case 11: // Rose Garden
        bgPatternAsset = AppAssetImages.design3;
        bgPatternOpacity = 0.90;
        break;
      case 12: // Lavender Bloom
        bgPatternAsset = AppAssetImages.design6;
        bgPatternOpacity = 0.90;
        break;
      case 13: // White Magnolia
        bgPatternAsset = AppAssetImages.design4;
        bgPatternOpacity = 0.35;
        break;
      case 14: // Minimal Gold
        bgPatternAsset = AppAssetImages.design8;
        bgPatternOpacity = 1.0;
        break;
      case 15: // Elegant Serif (Modern)
        bgPatternAsset = AppAssetImages.cardDesign1;
        bgPatternOpacity = 1.0;
        break;
      case 16: // Luxury Black & Gold
        bgPatternAsset = AppAssetImages.design5;
        bgPatternOpacity = 1.0;
        break;
    }

    // 6. Precompute cached colors with opacity
    final Color secondaryColorSemiOpaque = secondaryColor.withValues(alpha: 0.8);
    final Color secondaryColorLowOpacity = secondaryColor.withValues(alpha: 0.4);
    final Color secondaryColorCornerPaint = secondaryColor.withValues(alpha: 0.7);
    final Color bgPatternBlendColor = secondaryColor.withValues(alpha: 0.06);

    // 7. Resolve Typography (Strategy A)
    final fontTitle = spec?.fontTitle ?? 'Serif';
    final fontBody = spec?.fontBody ?? 'Serif';

    final TextStyle titleStyle = TemplateFontCache.getFont(
      fontTitle,
      textStyle: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w300,
        color: secondaryColor,
        letterSpacing: 1.5,
        shadows: [
          Shadow(
            blurRadius: 4.0,
            color: Colors.black.withValues(alpha: isDarkAccent ? 0.05 : 0.25),
            offset: const Offset(1.0, 1.0),
          ),
        ],
      ),
    );

    final TextStyle bodyLabelStyle = TemplateFontCache.getFont(
      fontBody,
      textStyle: TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.bold,
        color: secondaryColor.withValues(alpha: 0.8),
        letterSpacing: 3.0,
      ),
    );

    final TextStyle textContentStyle = TemplateFontCache.getFont(
      fontBody,
      textStyle: TextStyle(
        fontSize: 11,
        color: isDarkAccent ? secondaryColor.withValues(alpha: 0.8) : Colors.white70,
        height: 1.4,
      ),
    );

    final String collection = getCollectionForId(templateId);

    return TemplateUIModel(
      invitation: invitation,
      templateId: templateId,
      brideName: bName,
      groomName: gName,
      dateString: dateString,
      dateStringShort: dateStringShort,
      timeString: invitation.weddingTime,
      venueName: invitation.venueName.isEmpty ? 'The Grand Palace Resort' : invitation.venueName,
      venueAddress: invitation.venueAddress.isEmpty ? 'Main Palace Road, New Delhi' : invitation.venueAddress,
      personalMessage: invitation.personalMessage,
      collection: collection,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      gradientColors: gradientColors,
      isDarkAccent: isDarkAccent,
      bgPatternAsset: bgPatternAsset,
      bgPatternOpacity: bgPatternOpacity,
      bgPatternUrl: spec?.bgPatternUrl ?? '',
      hasBgPatternUrl: spec != null && spec.bgPatternUrl.isNotEmpty,
      skipBgPatternIdCheck: [13, 14, 15].contains(templateId),
      hideFrame: templateId == 15,
      secondaryColorSemiOpaque: secondaryColorSemiOpaque,
      secondaryColorLowOpacity: secondaryColorLowOpacity,
      secondaryColorCornerPaint: secondaryColorCornerPaint,
      bgPatternBlendColor: bgPatternBlendColor,
      titleStyle: titleStyle,
      bodyLabelStyle: bodyLabelStyle,
      textContentStyle: textContentStyle,
    );
  }
}
