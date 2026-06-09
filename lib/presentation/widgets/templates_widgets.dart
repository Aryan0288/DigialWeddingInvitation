import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/invitation_model.dart';
import '../../data/models/remote_template_model.dart';

// Optimized caching layer for GoogleFonts to prevent factory call overhead during scrolling.
class _TemplateFontCache {
  static final TextStyle _cormorantGaramondBase = GoogleFonts.cormorantGaramond();
  static final TextStyle _greatVibesBase = GoogleFonts.greatVibes();
  static final TextStyle _poppinsBase = GoogleFonts.poppins();

  static final Map<String, TextStyle> _dynamicCache = {};

  static TextStyle cormorantGaramond({TextStyle? textStyle}) {
    if (textStyle == null) return _cormorantGaramondBase;
    return _cormorantGaramondBase.merge(textStyle);
  }

  static TextStyle greatVibes({TextStyle? textStyle}) {
    if (textStyle == null) return _greatVibesBase;
    return _greatVibesBase.merge(textStyle);
  }

  static TextStyle poppins({TextStyle? textStyle}) {
    if (textStyle == null) return _poppinsBase;
    return _poppinsBase.merge(textStyle);
  }

  static TextStyle getFont(String fontName, {TextStyle? textStyle}) {
    final base = _dynamicCache.putIfAbsent(fontName, () {
      try {
        return GoogleFonts.getFont(fontName);
      } catch (_) {
        return const TextStyle();
      }
    });
    if (textStyle == null) return base;
    return base.merge(textStyle);
  }
}

// Central Factory
class InvitationTemplateFactory {
  static Widget getTemplate({
    required int templateId,
    required InvitationModel invitation,
    bool isPreview = true,
    List<RemoteTemplateModel> availableTemplates = const [],
  }) {
    // IDs 1–7 are static hardcoded widgets; 8+ are remote dynamic templates
    if (templateId > 7 && availableTemplates.any((t) => t.id == templateId)) {
      final templateSpec = availableTemplates.firstWhere((t) => t.id == templateId);
      return DynamicTemplateWidget(
        invitation: invitation,
        templateSpec: templateSpec,
        isPreview: isPreview,
      );
    }

    switch (templateId) {
      case 1:
        return GoldRedMandalaTemplate(invitation: invitation, isPreview: isPreview);
      case 2:
        return MaroonPeacockTemplate(invitation: invitation, isPreview: isPreview);
      case 3:
        return RoseGoldFloralTemplate(invitation: invitation, isPreview: isPreview);
      case 4:
        return MughalVintageArchTemplate(invitation: invitation, isPreview: isPreview);
      case 5:
        return LotusMandapSaveTheDateTemplate(invitation: invitation, isPreview: isPreview);
      case 6:
        return RegalMaroonSideArchTemplate(invitation: invitation, isPreview: isPreview);
      case 7:
        return DarkFloralEleganceTemplate(invitation: invitation, isPreview: isPreview);
      default:
        if (availableTemplates.any((t) => t.id == templateId)) {
          final templateSpec = availableTemplates.firstWhere((t) => t.id == templateId);
          return DynamicTemplateWidget(
            invitation: invitation,
            templateSpec: templateSpec,
            isPreview: isPreview,
          );
        }
        return GoldRedMandalaTemplate(invitation: invitation, isPreview: isPreview);
    }
  }
}

// -------------------------------------------------------------
// TEMPLATE 1: CLASSIC GOLD & RED (MANDALA THEME)
// -------------------------------------------------------------
class GoldRedMandalaTemplate extends StatelessWidget {
  final InvitationModel invitation;
  final bool isPreview;

  const GoldRedMandalaTemplate({
    super.key,
    required this.invitation,
    required this.isPreview,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, y');
    final String dateString = invitation.brideName.isEmpty && invitation.groomName.isEmpty
        ? 'Sunday, October 18, 2026'
        : dateFormat.format(invitation.weddingDate);

    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 360,
        height: 640,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF5B0000), // Deep Royal Red
                Color(0xFF8F0000), // Bright Crimson
                Color(0xFF3B0000), // Crimson Black
              ],
            ),
          ),
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
                    painter: MandalaPainter(color: const Color(0xFFD4AF37).withOpacity(0.15)),
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
                    painter: MandalaPainter(color: const Color(0xFFD4AF37).withOpacity(0.15)),
                  ),
                ),
              ),

              // Double Gold Border
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5), width: 1),
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
                                style: TextStyle(
                                  fontFamily: 'Serif',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD4AF37),
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'INVITATION',
                                style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 4.0,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFD4AF37).withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Couple Names
                              _buildCoupleNameText(invitation.brideName, 'Bride'),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'weds',
                                  style: TextStyle(
                                    fontFamily: 'Serif',
                                    fontStyle: FontStyle.italic,
                                    fontSize: 22,
                                    color: Color(0xFFD4AF37),
                                  ),
                                ),
                              ),
                              _buildCoupleNameText(invitation.groomName, 'Groom'),
                              _buildCouplePhotos(invitation, const Color(0xFFD4AF37), 'Royal'),
                              const SizedBox(height: 20),
                              
                              // Divider Line
                              Container(
                                width: 60,
                                height: 1.5,
                                color: const Color(0xFFD4AF37),
                              ),
                              const SizedBox(height: 28),
  
                              // Date
                              const Text(
                                'JOIN US ON',
                                style: TextStyle(
                                  fontSize: 9,
                                  letterSpacing: 2.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD4AF37),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                dateString.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'Serif',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF9F6F0),
                                  letterSpacing: 1.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                invitation.weddingTime,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 24),
  
                              // Venue
                              const Text(
                                'VENUE',
                                style: TextStyle(
                                  fontSize: 9,
                                  letterSpacing: 2.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD4AF37),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                invitation.venueName.isEmpty ? 'The Grand Palace Hall' : invitation.venueName,
                                style: const TextStyle(
                                  fontFamily: 'Serif',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                invitation.venueAddress.isEmpty ? 'Main Palace Road, New Delhi' : invitation.venueAddress,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white60,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 28),
  
                              // Personal Message
                              if (invitation.personalMessage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 24.0),
                                  child: Text(
                                    '" ${invitation.personalMessage} "',
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 11,
                                      color: Colors.white54,
                                      height: 1.4,
                                    ),
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

  Widget _buildCoupleNameText(String name, String fallback) {
    return Text(
      name.isEmpty ? fallback : name,
      style: const TextStyle(
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
      ),
      textAlign: TextAlign.center,
    );
  }
}

// -------------------------------------------------------------
// TEMPLATE 2: ROYAL MAROON & PEACOCK THEME
// -------------------------------------------------------------
class MaroonPeacockTemplate extends StatelessWidget {
  final InvitationModel invitation;
  final bool isPreview;

  const MaroonPeacockTemplate({
    super.key,
    required this.invitation,
    required this.isPreview,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, y');
    final String dateString = invitation.brideName.isEmpty && invitation.groomName.isEmpty
        ? 'Sunday, October 18, 2026'
        : dateFormat.format(invitation.weddingDate);

    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 360,
        height: 640,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF380208), // Rich Royal Maroon
                Color(0xFF180004), // Dark Midnight Maroon
              ],
            ),
          ),
          child: Stack(
            children: [
              // Peacock Feather Accents (Painters)
              Positioned(
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
              Positioned(
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
                      border: Border.all(color: const Color(0xFF00ADB5).withOpacity(0.4), width: 1), // Peacock Teal Accent
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.6), width: 1.5),
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
                                color: Color(0xFFD4AF37),
                                size: 32,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'WEDDING CELEBRATION',
                                style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 3.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00ADB5),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Names
                              _buildCoupleName(invitation.brideName, 'Bride'),
                              const SizedBox(height: 10),
                              const Text(
                                '&',
                                style: TextStyle(
                                  fontFamily: 'Serif',
                                  fontSize: 26,
                                  color: Color(0xFFD4AF37),
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildCoupleName(invitation.groomName, 'Groom'),
                              _buildCouplePhotos(invitation, const Color(0xFFD4AF37), 'Royal'),
                              const SizedBox(height: 20),
  
                              // Date Panel
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.symmetric(
                                    horizontal: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.4), width: 1),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      dateString.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      invitation.weddingTime,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF00ADB5),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),
  
                              // Venue
                              const Text(
                                'EVENT VENUE',
                                style: TextStyle(
                                  fontSize: 9,
                                  letterSpacing: 2.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00ADB5),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                invitation.venueName.isEmpty ? 'Royal Heritage Mansion' : invitation.venueName,
                                style: const TextStyle(
                                  fontFamily: 'Serif',
                                  fontSize: 15,
                                  color: Color(0xFFF9F6F0),
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                invitation.venueAddress.isEmpty ? 'Jodhpur, Rajasthan' : invitation.venueAddress,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white54,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
  
                              // Message
                              if (invitation.personalMessage.isNotEmpty)
                                Text(
                                  '" ${invitation.personalMessage} "',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 11,
                                    color: Colors.white38,
                                    height: 1.4,
                                  ),
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

  Widget _buildCoupleName(String name, String fallback) {
    return Text(
      name.isEmpty ? fallback : name,
      style: const TextStyle(
        fontFamily: 'Serif',
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: Color(0xFFD4AF37),
        letterSpacing: 1.0,
      ),
      textAlign: TextAlign.center,
    );
  }
}

// -------------------------------------------------------------
// TEMPLATE 3: ELEGANT ROSE GOLD (FLORAL THEME)
// -------------------------------------------------------------
class RoseGoldFloralTemplate extends StatelessWidget {
  final InvitationModel invitation;
  final bool isPreview;

  const RoseGoldFloralTemplate({
    super.key,
    required this.invitation,
    required this.isPreview,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, y');
    final String dateString = invitation.brideName.isEmpty && invitation.groomName.isEmpty
        ? 'Sunday, October 18, 2026'
        : dateFormat.format(invitation.weddingDate);

    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 360,
        height: 640,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFF0F2), // Light Soft Rose Gold
                Color(0xFFEAD1D5), // Deep Elegant Rose
                Color(0xFFD8B2B7), // Rose Gold Shimmer
              ],
            ),
          ),
          child: Stack(
            children: [
              // Floral Frame Corners
              Positioned(
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
                  angle: math.pi,
                  child: SizedBox(
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
                      border: Border.all(color: const Color(0xFFB76E79).withOpacity(0.6), width: 1.0),
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
                            color: Color(0xFFB76E79),
                            size: 24,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'SAVE THE DATE FOR THE WEDDING OF',
                            style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFB76E79),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
                          // Names
                          _buildCoupleName(invitation.brideName, 'Bride'),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.0),
                            child: Text(
                              '&',
                              style: TextStyle(
                                fontFamily: 'Serif',
                                fontSize: 22,
                                color: Color(0xFFB76E79),
                              ),
                            ),
                          ),
                          _buildCoupleName(invitation.groomName, 'Groom'),
                          _buildCouplePhotos(invitation, const Color(0xFFB76E79), 'Floral'),
                          const SizedBox(height: 20),
  
                          // Date & Time
                          Text(
                            dateString,
                            style: const TextStyle(
                              fontFamily: 'Serif',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A3437),
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            invitation.weddingTime,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7A5C61),
                            ),
                          ),
                          const SizedBox(height: 24),
  
                          // Divider
                          Container(
                            width: 40,
                            height: 1,
                            color: const Color(0xFFB76E79).withOpacity(0.5),
                          ),
                          const SizedBox(height: 24),
  
                          // Venue
                          Text(
                            invitation.venueName.isEmpty ? 'The Garden Estate' : invitation.venueName,
                            style: const TextStyle(
                              fontFamily: 'Serif',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A3437),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            invitation.venueAddress.isEmpty ? 'Lutyens Zone, New Delhi' : invitation.venueAddress,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF7A5C61),
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
  
                          // Message
                          if (invitation.personalMessage.isNotEmpty)
                            Text(
                              '" ${invitation.personalMessage} "',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 11,
                                color: Color(0xFF9E7E83),
                                height: 1.4,
                              ),
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

  Widget _buildCoupleName(String name, String fallback) {
    return Text(
      name.isEmpty ? fallback : name,
      style: const TextStyle(
        fontFamily: 'Serif',
        fontSize: 34,
        fontWeight: FontWeight.w300,
        color: Color(0xFF4A3437),
        letterSpacing: 1.0,
      ),
      textAlign: TextAlign.center,
    );
  }
}

// -------------------------------------------------------------
// TEMPLATE 4: MUGHAL HERITAGE (VINTAGE ARCH)
// -------------------------------------------------------------
class MughalVintageArchTemplate extends StatelessWidget {
  final InvitationModel invitation;
  final bool isPreview;

  const MughalVintageArchTemplate({
    super.key,
    required this.invitation,
    required this.isPreview,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, y');
    final String dateString = invitation.brideName.isEmpty && invitation.groomName.isEmpty
        ? 'Sunday, October 18, 2026'
        : dateFormat.format(invitation.weddingDate);

    final goldColor = const Color(0xFFD4AF37);
    final maroonColor = const Color(0xFF5B0000);

    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 360,
        height: 640,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF5EFEB),
                Color(0xFFEADCC9),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Custom Mughal Arch Frame (fills top and sides with Maroon, inside is vintage cream)
              Positioned.fill(
                child: CustomPaint(
                  painter: MughalArchPainter(
                    archColor: goldColor,
                    outerBgColor: maroonColor,
                  ),
                ),
              ),

              // Hanging Lanterns
              Positioned.fill(
                child: CustomPaint(
                  painter: MughalLanternsPainter(goldColor: goldColor),
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
                        invitation.brideName.isEmpty && invitation.groomName.isEmpty
                            ? 'THE SINGH & GUPTA FAMILIES'
                            : 'THE FAMILY OF BRIDE & GROOM',
                        style: _TemplateFontCache.cormorantGaramond(
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5B0000),
                            letterSpacing: 2.0,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      
                      // Invitation message line
                      Text(
                        'cordially invite you to the wedding of their son & daughter',
                        style: _TemplateFontCache.greatVibes(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF704A1B),
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),

                      // Bride Name
                      Text(
                        invitation.brideName.isEmpty ? 'Prerna Singh' : invitation.brideName,
                        style: _TemplateFontCache.cormorantGaramond(
                          textStyle: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5B0000),
                            letterSpacing: 1.0,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      // weds
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          'weds',
                          style: _TemplateFontCache.greatVibes(
                            textStyle: const TextStyle(
                              fontSize: 18,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Groom Name
                      Text(
                        invitation.groomName.isEmpty ? 'Sumit Gupta' : invitation.groomName,
                        style: _TemplateFontCache.cormorantGaramond(
                          textStyle: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5B0000),
                            letterSpacing: 1.0,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      Text(
                        'ARE INVITING FOR THEIR WEDDING CEREMONY',
                        style: _TemplateFontCache.poppins(
                          textStyle: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Color(0xFF704A1B),
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // Date and Time Box
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.symmetric(
                            horizontal: BorderSide(color: goldColor.withOpacity(0.5), width: 1),
                          ),
                        ),
                        child: Text(
                          '${dateString.toUpperCase()} | ${invitation.weddingTime.toUpperCase()}',
                          style: _TemplateFontCache.cormorantGaramond(
                            textStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5B0000),
                              letterSpacing: 0.5,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Venue Title & Address
                      Text(
                        invitation.venueName.isEmpty ? 'AT THE CHURCH PREMISE, ACCRA' : invitation.venueName.toUpperCase(),
                        style: _TemplateFontCache.poppins(
                          textStyle: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5B0000),
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        invitation.venueAddress.isEmpty
                            ? 'Assemblies of God, Family Praise, Mariville Homes'
                            : invitation.venueAddress,
                        style: _TemplateFontCache.poppins(
                          textStyle: const TextStyle(
                            fontSize: 8,
                            color: Color(0xFF704A1B),
                          ),
                        ),
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
                                style: _TemplateFontCache.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5B0000),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '+233541576039\n+233546378549',
                                style: _TemplateFontCache.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 7,
                                    color: Color(0xFF704A1B),
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            'Reception to Follow',
                            style: _TemplateFontCache.greatVibes(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFFD4AF37),
                              ),
                            ),
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
                  child: _buildCoupleFrameOrIllustration(
                    invitation: invitation,
                    accentColor: goldColor,
                    frameStyle: 'Mughal',
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

// -------------------------------------------------------------
// TEMPLATE 5: LOTUS MANDAP (SAVE THE DATE)
// -------------------------------------------------------------
class LotusMandapSaveTheDateTemplate extends StatelessWidget {
  final InvitationModel invitation;
  final bool isPreview;

  const LotusMandapSaveTheDateTemplate({
    super.key,
    required this.invitation,
    required this.isPreview,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, y');
    final String dateString = invitation.brideName.isEmpty && invitation.groomName.isEmpty
        ? 'February 5th, 2025'
        : dateFormat.format(invitation.weddingDate);

    final mandapColor = const Color(0xFFD47F74);

    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 360,
        height: 640,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF6F4),
                Color(0xFFFFECE7),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Watercolor peach wash containers (SaaS dynamic paint simulation)
              Positioned(
                top: -60,
                left: 20,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFDD5CD).withOpacity(0.35),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: -40,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFDD5CD).withOpacity(0.25),
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
                        color: const Color(0xFFD4AF37).withOpacity(0.6),
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ),

              // Floating watercolor leaves/petals in background (soft decorations)
              Positioned(
                top: 40,
                left: 24,
                child: Icon(Icons.spa_outlined, color: mandapColor.withOpacity(0.12), size: 28),
              ),
              Positioned(
                top: 80,
                right: 32,
                child: Icon(Icons.spa_outlined, color: mandapColor.withOpacity(0.12), size: 22),
              ),

              // Palace Dome Mandap structure at bottom center
              Positioned.fill(
                child: CustomPaint(
                  painter: PalaceMandapPainter(color: mandapColor.withOpacity(0.75)),
                ),
              ),

              // Lotus Flowers flanking column bases at the bottom
              Positioned.fill(
                child: CustomPaint(
                  painter: LotusFlowerPainter(lotusColor: const Color(0xFFF48FB1)),
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
                      style: _TemplateFontCache.greatVibes(
                        textStyle: TextStyle(
                          fontSize: 42,
                          color: mandapColor,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(
                              color: Colors.white,
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // To celebrate the wedding of
                    Text(
                      'TO CELEBRATE THE WEDDING OF',
                      style: _TemplateFontCache.poppins(
                        textStyle: const TextStyle(
                          fontSize: 8,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B645C),
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),

                    // Couple Names
                    Text(
                      invitation.brideName.isEmpty && invitation.groomName.isEmpty
                          ? 'Lokesh & Priya'
                          : '${invitation.brideName} & ${invitation.groomName}',
                      style: _TemplateFontCache.greatVibes(
                        textStyle: const TextStyle(
                          fontSize: 34,
                          color: Color(0xFFE07A5F),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Date
                    Text(
                      dateString.toUpperCase(),
                      style: _TemplateFontCache.cormorantGaramond(
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2A26),
                          letterSpacing: 1.0,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      invitation.weddingTime,
                      style: _TemplateFontCache.poppins(
                        textStyle: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6B645C),
                        ),
                      ),
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
                  child: _buildCoupleFrameOrIllustration(
                    invitation: invitation,
                    accentColor: mandapColor,
                    frameStyle: 'LotusMandap',
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

// -------------------------------------------------------------
// TEMPLATE 6: REGAL MAROON (WAVY SIDE ARCH)
// -------------------------------------------------------------
class RegalMaroonSideArchTemplate extends StatelessWidget {
  final InvitationModel invitation;
  final bool isPreview;

  const RegalMaroonSideArchTemplate({
    super.key,
    required this.invitation,
    required this.isPreview,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, y');
    final String dateString = invitation.brideName.isEmpty && invitation.groomName.isEmpty
        ? 'January 30th, 2024'
        : dateFormat.format(invitation.weddingDate);

    final maroonColor = const Color(0xFF600018);
    final goldColor = const Color(0xFFD4AF37);

    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 360,
        height: 640,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFFFAF7F2), // Elegant warm cream
          child: Stack(
            children: [
              // Wavy side panel on the right side
              Positioned.fill(
                child: CustomPaint(
                  painter: WavySideArchPainter(
                    maroonColor: maroonColor,
                    goldColor: goldColor,
                  ),
                ),
              ),

              // Gold hanging ornaments/foliage on the top right maroon panel
              Positioned(
                top: 20,
                right: 20,
                child: Opacity(
                  opacity: 0.25,
                  child: Icon(Icons.filter_vintage, color: goldColor, size: 40),
                ),
              ),
              Positioned(
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
                      invitation.brideName.isEmpty && invitation.groomName.isEmpty
                          ? 'THE SINGH & GUPTA FAMILIES'
                          : 'THE FAMILY INVITATION',
                      style: _TemplateFontCache.cormorantGaramond(
                        textStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: maroonColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // invite line
                    Text(
                      'cordially invite you to the wedding of their son & daughter',
                      style: _TemplateFontCache.poppins(
                        textStyle: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF6B645C),
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bride Name
                    Text(
                      invitation.brideName.isEmpty ? 'Prerna Singh' : invitation.brideName,
                      style: _TemplateFontCache.cormorantGaramond(
                        textStyle: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: maroonColor,
                          height: 1.1,
                        ),
                      ),
                    ),
                    
                    // weds / &
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        '&',
                        style: _TemplateFontCache.greatVibes(
                          textStyle: TextStyle(
                            fontSize: 22,
                            color: goldColor,
                          ),
                        ),
                      ),
                    ),

                    // Groom Name
                    Text(
                      invitation.groomName.isEmpty ? 'Sumit Gupta' : invitation.groomName,
                      style: _TemplateFontCache.cormorantGaramond(
                        textStyle: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: maroonColor,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // invitation statement
                    Text(
                      'ARE INVITING FOR THEIR WEDDING CEREMONY',
                      style: _TemplateFontCache.poppins(
                        textStyle: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: maroonColor.withOpacity(0.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Date & Time Grid
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, color: maroonColor, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dateString,
                            style: _TemplateFontCache.cormorantGaramond(
                              textStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D2A26),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: maroonColor, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          invitation.weddingTime,
                          style: _TemplateFontCache.poppins(
                            textStyle: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF6B645C),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Venue Location
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_outlined, color: maroonColor, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                invitation.venueName.isEmpty ? 'The Church Premise' : invitation.venueName,
                                style: _TemplateFontCache.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D2A26),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                invitation.venueAddress.isEmpty
                                    ? 'Assemblies of God, Mariville Homes, Accra'
                                    : invitation.venueAddress,
                                style: _TemplateFontCache.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 8,
                                    color: Color(0xFF6B645C),
                                    height: 1.3,
                                  ),
                                ),
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
                      style: _TemplateFontCache.poppins(
                        textStyle: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B645C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Text(
                      'Reception to Follow',
                      style: _TemplateFontCache.greatVibes(
                        textStyle: TextStyle(
                          fontSize: 18,
                          color: goldColor,
                        ),
                      ),
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
                  child: _buildCoupleFrameOrIllustration(
                    invitation: invitation,
                    accentColor: maroonColor,
                    frameStyle: 'WavyMaroon',
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

// -------------------------------------------------------------
// TEMPLATE 7: DARK FLORAL ELEGANCE (HYBRID IMAGE-BACKED)
// -------------------------------------------------------------
class DarkFloralEleganceTemplate extends StatelessWidget {
  final InvitationModel invitation;
  final bool isPreview;

  const DarkFloralEleganceTemplate({
    super.key,
    required this.invitation,
    required this.isPreview,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, y');
    final String dateString = invitation.brideName.isEmpty && invitation.groomName.isEmpty
        ? 'October 18, 2026'
        : dateFormat.format(invitation.weddingDate);

    const goldColor = Color(0xFFD4AF37);
    const whiteColor = Colors.white;
    const creamColor = Color(0xFFF5EDD8);

    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 360,
        height: 640,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // --- Layer 1: Full-bleed background image (design stays 100% intact) ---
            Image.asset(
              'lib/assests/png/card_design_1.png',
              fit: BoxFit.cover,
              width: 360,
              height: 640,
              errorBuilder: (context, error, stackTrace) {
                // Fallback: dark navy solid if image fails to load
                return Container(
                  color: const Color(0xFF0D1219),
                  child: const Center(
                    child: Icon(Icons.image_not_supported_outlined,
                        color: Color(0xFFD4AF37), size: 48),
                  ),
                );
              },
            ),

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
                    style: _TemplateFontCache.poppins(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: goldColor,
                        letterSpacing: 2.5,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),

                  // Thin gold divider
                  Container(
                    width: 120,
                    height: 1.0,
                    color: goldColor.withOpacity(0.6),
                  ),
                  const SizedBox(height: 14),

                  // Invite line
                  Text(
                    'Together with their families',
                    style: _TemplateFontCache.poppins(
                      textStyle: const TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.2,
                        color: creamColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Bride Name
                  Text(
                    invitation.brideName.isEmpty ? 'Prerna Singh' : invitation.brideName,
                    style: _TemplateFontCache.cormorantGaramond(
                      textStyle: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: whiteColor,
                        letterSpacing: 1.2,
                        height: 1.1,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Weds in script
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      'weds',
                      style: _TemplateFontCache.greatVibes(
                        textStyle: const TextStyle(
                          fontSize: 22,
                          color: goldColor,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Groom Name
                  Text(
                    invitation.groomName.isEmpty ? 'Sumit Gupta' : invitation.groomName,
                    style: _TemplateFontCache.cormorantGaramond(
                      textStyle: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: whiteColor,
                        letterSpacing: 1.2,
                        height: 1.1,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),

                  // Thin gold divider
                  Container(
                    width: 100,
                    height: 1.0,
                    color: goldColor.withOpacity(0.5),
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
                          '$dateString  •  ${invitation.weddingTime}',
                          style: _TemplateFontCache.poppins(
                            textStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: creamColor,
                              letterSpacing: 0.5,
                            ),
                          ),
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
                    invitation.venueName.isEmpty
                        ? 'The Grand Palace Hall'
                        : invitation.venueName,
                    style: _TemplateFontCache.cormorantGaramond(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: whiteColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Venue Address
                  Text(
                    invitation.venueAddress.isEmpty
                        ? 'Main Palace Road, New Delhi'
                        : invitation.venueAddress,
                    style: _TemplateFontCache.poppins(
                      textStyle: TextStyle(
                        fontSize: 9,
                        color: creamColor.withOpacity(0.8),
                        height: 1.3,
                      ),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Personal message
                  if (invitation.personalMessage.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      '" ${invitation.personalMessage} "',
                      style: _TemplateFontCache.poppins(
                        textStyle: TextStyle(
                          fontSize: 8.5,
                          fontStyle: FontStyle.italic,
                          color: creamColor.withOpacity(0.7),
                          height: 1.4,
                        ),
                      ),
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
    );
  }
}

// -------------------------------------------------------------
// IMAGE RENDER HELPERS FOR COUPLE PHOTOS OR ILLUSTRATIONS
// -------------------------------------------------------------
Widget _buildCoupleFrameOrIllustration({
  required InvitationModel invitation,
  required Color accentColor,
  required String frameStyle,
}) {
  final hasBride = invitation.brideImageUrl.isNotEmpty;
  final hasGroom = invitation.groomImageUrl.isNotEmpty;

  if (hasBride || hasGroom) {
    const double size = 50.0;
    ImageProvider brideProvider = invitation.brideImageUrl.startsWith('data:image') || !invitation.brideImageUrl.startsWith('http')
        ? getCachedMemoryImage(invitation.brideImageUrl)
        : NetworkImage(invitation.brideImageUrl) as ImageProvider;
        
    ImageProvider groomProvider = invitation.groomImageUrl.startsWith('data:image') || !invitation.groomImageUrl.startsWith('http')
        ? getCachedMemoryImage(invitation.groomImageUrl)
        : NetworkImage(invitation.groomImageUrl) as ImageProvider;

    Widget frameWidget(ImageProvider provider, String side) {
      ShapeBorder shape;
      if (frameStyle == 'Mughal') {
        shape = RoundedRectangleBorder(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(size / 2),
            topRight: Radius.circular(size / 2),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(4),
          ),
          side: BorderSide(color: accentColor, width: 1.5),
        );
      } else if (frameStyle == 'LotusMandap') {
        shape = CircleBorder(
          side: BorderSide(color: accentColor, width: 1.5),
        );
      } else {
        shape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: accentColor, width: 1.5),
        );
      }

      return Container(
        width: size,
        height: size,
        decoration: ShapeDecoration(
          shape: shape,
          image: DecorationImage(
            image: provider,
            fit: BoxFit.cover,
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (invitation.brideImageUrl.isNotEmpty)
          frameWidget(brideProvider, 'bride'),
        if (invitation.brideImageUrl.isNotEmpty && invitation.groomImageUrl.isNotEmpty) ...[
          const SizedBox(width: 6),
          Icon(Icons.favorite, color: accentColor, size: 10),
          const SizedBox(width: 6),
        ],
        if (invitation.groomImageUrl.isNotEmpty)
          frameWidget(groomProvider, 'groom'),
      ],
    );
  } else {
    return CustomPaint(
      painter: TraditionalCoupleIllustrationPainter(
        primaryColor: accentColor.withOpacity(0.15),
        accentColor: accentColor,
      ),
    );
  }
}

Widget _buildCoupleName(String name, String fallback) {
  return Text(
    name.isEmpty ? fallback : name,
    style: const TextStyle(
      fontFamily: 'Serif',
      fontSize: 34,
      fontWeight: FontWeight.w300,
      color: Color(0xFF4A3437),
      letterSpacing: 1.0,
    ),
    textAlign: TextAlign.center,
  );
}

// -------------------------------------------------------------
// VECTOR PAINTERS FOR LUXURY MOTIFS
// -------------------------------------------------------------

// 1. Intricate Circular Mandala
class MandalaPainter extends CustomPainter {
  final Color color;
  MandalaPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2;

    // Draw concentric circles
    for (double r = 10; r <= maxRadius; r += 15) {
      canvas.drawCircle(center, r, paint);
    }

    // Draw radial lines
    const spokes = 24;
    for (int i = 0; i < spokes; i++) {
      final angle = (i * 2 * math.pi) / spokes;
      final outer = center + Offset(math.cos(angle) * maxRadius, math.sin(angle) * maxRadius);
      canvas.drawLine(center, outer, paint);
    }

    // Draw intricate petal details
    for (double r = 30; r <= maxRadius; r += 30) {
      final path = Path();
      const petals = 12;
      for (int i = 0; i <= petals; i++) {
        final angle = (i * 2 * math.pi) / petals;
        final x = center.dx + math.cos(angle) * r;
        final y = center.dy + math.sin(angle) * r;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          final prevAngle = ((i - 1) * 2 * math.pi) / petals;
          final ctrlAngle = (prevAngle + angle) / 2;
          final ctrlX = center.dx + math.cos(ctrlAngle) * (r + 15);
          final ctrlY = center.dy + math.sin(ctrlAngle) * (r + 15);
          path.quadraticBezierTo(ctrlX, ctrlY, x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant MandalaPainter oldDelegate) => oldDelegate.color != color;
}

// 2. Stylized Peacock Feather Motif
class PeacockFeatherPainter extends CustomPainter {
  final bool isRotated;
  PeacockFeatherPainter({this.isRotated = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (isRotated) {
      canvas.translate(size.width, size.height);
      canvas.rotate(math.pi);
    }

    final goldPaint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final tealPaint = Paint()
      ..color = const Color(0xFF00ADB5).withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    
    // Draw feather stem
    path.quadraticBezierTo(size.width * 0.4, size.height * 0.5, size.width * 0.8, size.height * 0.2);
    canvas.drawPath(path, goldPaint);

    // Draw eye of the feather
    final eyeCenter = Offset(size.width * 0.8, size.height * 0.2);
    canvas.drawCircle(eyeCenter, 20, goldPaint);
    canvas.drawCircle(eyeCenter, 12, tealPaint);

    // Draw barbs (feather lines)
    for (double i = 0.2; i <= 0.8; i += 0.1) {
      final t = i;
      final start = Offset(size.width * t * 0.5, size.height - (size.height * (1-t) * 0.8));
      final endLeft = start + Offset(-15, -20);
      final endRight = start + Offset(15, -20);
      canvas.drawLine(start, endLeft, goldPaint);
      canvas.drawLine(start, endRight, goldPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 3. Delicate Floral Corners
class FloralCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB76E79).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Corner branches
    canvas.drawLine(const Offset(0, 0), const Offset(60, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, 60), paint);

    // Draw delicate leaf loops
    final path = Path();
    path.moveTo(10, 0);
    path.quadraticBezierTo(20, 15, 30, 0);
    path.moveTo(35, 0);
    path.quadraticBezierTo(42, 10, 50, 0);

    path.moveTo(0, 10);
    path.quadraticBezierTo(15, 20, 0, 30);
    path.moveTo(0, 35);
    path.quadraticBezierTo(10, 42, 0, 50);

    canvas.drawPath(path, paint);

    // Draw a small floral bulb
    final bulbPaint = Paint()
      ..color = const Color(0xFFB76E79).withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(15, 15), 4, bulbPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -------------------------------------------------------------
// DYNAMIC REMOTE INJECTED TEMPLATE SCREEN
// -------------------------------------------------------------
// -------------------------------------------------------------
// VECTOR PAINTER FOR DYNAMIC CARD CORNERS
// -------------------------------------------------------------
class GoldCornerPainter extends CustomPainter {
  final Color color;
  GoldCornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final double lSize = 18.0;
    final double offset = 6.0;

    // Top-left corner
    canvas.drawLine(Offset(offset, offset), Offset(offset + lSize, offset), paint);
    canvas.drawLine(Offset(offset, offset), Offset(offset, offset + lSize), paint);
    
    // Top-right corner
    canvas.drawLine(Offset(size.width - offset, offset), Offset(size.width - offset - lSize, offset), paint);
    canvas.drawLine(Offset(size.width - offset, offset), Offset(size.width - offset, offset + lSize), paint);
    
    // Bottom-left corner
    canvas.drawLine(Offset(offset, size.height - offset), Offset(offset + lSize, size.height - offset), paint);
    canvas.drawLine(Offset(offset, size.height - offset), Offset(offset, size.height - offset - lSize), paint);
    
    // Bottom-right corner
    canvas.drawLine(Offset(size.width - offset, size.height - offset), Offset(size.width - offset - lSize, size.height - offset), paint);
    canvas.drawLine(Offset(size.width - offset, size.height - offset), Offset(size.width - offset, size.height - offset - lSize), paint);

    // Subtle inner dots for vintage luxury feel
    final dotPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(offset + 3, offset + 3), 1.5, dotPaint);
    canvas.drawCircle(Offset(size.width - offset - 3, offset + 3), 1.5, dotPaint);
    canvas.drawCircle(Offset(offset + 3, size.height - offset - 3), 1.5, dotPaint);
    canvas.drawCircle(Offset(size.width - offset - 3, size.height - offset - 3), 1.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -------------------------------------------------------------
// DYNAMIC REMOTE INJECTED TEMPLATE SCREEN
// -------------------------------------------------------------
class DynamicTemplateWidget extends StatelessWidget {
  final InvitationModel invitation;
  final RemoteTemplateModel templateSpec;
  final bool isPreview;

  const DynamicTemplateWidget({
    super.key,
    required this.invitation,
    required this.templateSpec,
    this.isPreview = true,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, y');
    final String dateString = invitation.brideName.isEmpty && invitation.groomName.isEmpty
        ? 'Sunday, October 18, 2026'
        : dateFormat.format(invitation.weddingDate);

    final Color primaryColor = HexColor.fromHex(templateSpec.primaryColorHex);
    final Color secondaryColor = HexColor.fromHex(templateSpec.secondaryColorHex);
    final List<Color> gradientColors = templateSpec.bgGradientHex
        .map((hex) => HexColor.fromHex(hex))
        .toList();

    final isDarkAccent = secondaryColor.computeLuminance() < 0.3;

    final TextStyle titleStyle = _TemplateFontCache.getFont(
      templateSpec.fontTitle,
      textStyle: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w300,
        color: secondaryColor,
        letterSpacing: 1.5,
        shadows: [
          Shadow(
            blurRadius: 4.0,
            color: Colors.black.withOpacity(isDarkAccent ? 0.05 : 0.25),
            offset: const Offset(1.0, 1.0),
          ),
        ],
      ),
    );

    final TextStyle bodyLabelStyle = _TemplateFontCache.getFont(
      templateSpec.fontBody,
      textStyle: TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.bold,
        color: secondaryColor.withOpacity(0.8),
        letterSpacing: 3.0,
      ),
    );

    final TextStyle textContentStyle = _TemplateFontCache.getFont(
      templateSpec.fontBody,
      textStyle: TextStyle(
        fontSize: 11,
        color: isDarkAccent ? secondaryColor.withOpacity(0.8) : Colors.white70,
        height: 1.4,
      ),
    );

    final collection = _getCollectionForId(templateSpec.id);

    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 360,
        height: 640,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors.isNotEmpty 
                  ? gradientColors 
                  : [primaryColor, primaryColor.withOpacity(0.8)],
            ),
          ),
          child: Stack(
            children: [
              // Load dynamic network background pattern with safe fallback
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: templateSpec.bgPatternUrl,
                  fit: BoxFit.cover,
                  color: secondaryColor.withOpacity(0.06),
                  colorBlendMode: BlendMode.dstIn,
                  placeholder: (context, url) => const SizedBox.shrink(),
                  errorWidget: (context, url, error) => const SizedBox.shrink(),
                ),
              ),

              // Subtle overall inner glow
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 30,
                        spreadRadius: -20,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),

              // Elegant thin double border frame
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: secondaryColor.withOpacity(0.8), width: 1.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: secondaryColor.withOpacity(0.4), width: 1),
                        ),
                        child: Stack(
                          children: [
                            // Render vintage luxury gold corners inside the borders
                            Positioned.fill(
                              child: CustomPaint(
                                painter: GoldCornerPainter(color: secondaryColor.withOpacity(0.7)),
                              ),
                            ),
                            
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: _buildStructuralLayout(
                                  collection: collection,
                                  secondaryColor: secondaryColor,
                                  titleStyle: titleStyle,
                                  bodyLabelStyle: bodyLabelStyle,
                                  textContentStyle: textContentStyle,
                                  dateString: dateString,
                                  isDarkAccent: isDarkAccent,
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildStructuralLayout({
    required String collection,
    required Color secondaryColor,
    required TextStyle titleStyle,
    required TextStyle bodyLabelStyle,
    required TextStyle textContentStyle,
    required String dateString,
    required bool isDarkAccent,
  }) {
    switch (collection) {
      case 'Royal':
        return _buildRoyalLayout(secondaryColor, titleStyle, bodyLabelStyle, textContentStyle, dateString, isDarkAccent);
      case 'Luxury':
        return _buildLuxuryLayout(secondaryColor, titleStyle, bodyLabelStyle, textContentStyle, dateString, isDarkAccent);
      case 'Floral':
        return _buildFloralLayout(secondaryColor, titleStyle, bodyLabelStyle, textContentStyle, dateString, isDarkAccent);
      case 'Modern':
      default:
        return _buildModernLayout(secondaryColor, titleStyle, bodyLabelStyle, textContentStyle, dateString, isDarkAccent);
    }
  }

  // ROYAL LAYOUT (Centered, Traditional Arches/Mandalas, Sanskrit sub-header)
  Widget _buildRoyalLayout(Color secondaryColor, TextStyle titleStyle, TextStyle bodyLabelStyle, TextStyle textContentStyle, String dateString, bool isDarkAccent) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        const Text(
          'शुभ विवाह',
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4AF37),
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 12),
        Text('SHUBH VIVAH INVITATION', style: bodyLabelStyle),
        
        _buildCouplePhotos(invitation, secondaryColor, 'Royal'),
        
        Text(invitation.brideName.isEmpty ? 'Bride' : invitation.brideName, style: titleStyle, textAlign: TextAlign.center),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text('weds', style: TextStyle(fontFamily: 'Serif', fontStyle: FontStyle.italic, fontSize: 18, color: secondaryColor)),
        ),
        Text(invitation.groomName.isEmpty ? 'Groom' : invitation.groomName, style: titleStyle, textAlign: TextAlign.center),
        const SizedBox(height: 16),

        Container(width: 50, height: 1.5, color: secondaryColor),
        const SizedBox(height: 16),

        Text('JOIN US ON', style: bodyLabelStyle),
        const SizedBox(height: 6),
        Text(
          dateString.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDarkAccent ? secondaryColor : const Color(0xFFF9F6F0),
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        Text(invitation.weddingTime, style: TextStyle(fontSize: 11, color: isDarkAccent ? secondaryColor.withOpacity(0.8) : Colors.white70)),
        const SizedBox(height: 16),

        Text('VENUE', style: bodyLabelStyle),
        const SizedBox(height: 4),
        Text(
          invitation.venueName.isEmpty ? 'The Grand Palace Resort' : invitation.venueName,
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDarkAccent ? secondaryColor : const Color(0xFFF9F6F0),
          ),
          textAlign: TextAlign.center,
        ),
        Text(invitation.venueAddress.isEmpty ? 'Main Palace Road, New Delhi' : invitation.venueAddress, style: textContentStyle, textAlign: TextAlign.center),
        const SizedBox(height: 12),

        if (invitation.personalMessage.isNotEmpty)
          Text('" ${invitation.personalMessage} "', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 10, color: isDarkAccent ? secondaryColor.withOpacity(0.7) : Colors.white54, height: 1.3), textAlign: TextAlign.center),
      ],
    );
  }

  // LUXURY LAYOUT (Minimalist Asymmetric borders, fine-art margins, high fashion serif)
  Widget _buildLuxuryLayout(Color secondaryColor, TextStyle titleStyle, TextStyle bodyLabelStyle, TextStyle textContentStyle, String dateString, bool isDarkAccent) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('MEMORABLE CELEBRATION', style: bodyLabelStyle.copyWith(fontSize: 8)),
            Icon(Icons.spa_outlined, color: secondaryColor, size: 16),
          ],
        ),
        const SizedBox(height: 20),
        
        Text(invitation.brideName.isEmpty ? 'BRIDE' : invitation.brideName.toUpperCase(), style: titleStyle.copyWith(fontSize: 26, fontWeight: FontWeight.w600, letterSpacing: 2.0)),
        Text('AND', style: bodyLabelStyle.copyWith(fontSize: 9, letterSpacing: 4.0)),
        Text(invitation.groomName.isEmpty ? 'GROOM' : invitation.groomName.toUpperCase(), style: titleStyle.copyWith(fontSize: 26, fontWeight: FontWeight.w600, letterSpacing: 2.0)),
        
        _buildCouplePhotos(invitation, secondaryColor, 'Luxury'),
        
        const SizedBox(height: 12),
        Container(height: 1, color: secondaryColor.withOpacity(0.3)),
        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WHEN', style: bodyLabelStyle),
                  const SizedBox(height: 4),
                  Text(dateString, style: textContentStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 11)),
                  Text(invitation.weddingTime, style: textContentStyle.copyWith(fontSize: 10)),
                ],
              ),
            ),
            Container(width: 1, height: 40, color: secondaryColor.withOpacity(0.3)),
            const SizedBox(width: 16),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WHERE', style: bodyLabelStyle),
                  const SizedBox(height: 4),
                  Text(invitation.venueName.isEmpty ? 'The Ivory Mansion' : invitation.venueName, style: textContentStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(invitation.venueAddress.isEmpty ? 'New Delhi, India' : invitation.venueAddress, style: textContentStyle.copyWith(fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (invitation.personalMessage.isNotEmpty)
          Text('" ${invitation.personalMessage} "', style: textContentStyle.copyWith(fontStyle: FontStyle.italic, fontSize: 9.5, height: 1.3)),
      ],
    );
  }

  // FLORAL LAYOUT (Water-color feel, script typography, circular leaf-borders)
  Widget _buildFloralLayout(Color secondaryColor, TextStyle titleStyle, TextStyle bodyLabelStyle, TextStyle textContentStyle, String dateString, bool isDarkAccent) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Icon(Icons.filter_vintage_outlined, color: secondaryColor, size: 28),
        const SizedBox(height: 8),
        Text('SAVE THE DATE', style: bodyLabelStyle.copyWith(fontSize: 8, letterSpacing: 2.0)),
        const SizedBox(height: 12),

        Text(invitation.brideName.isEmpty ? 'Bride' : invitation.brideName, style: titleStyle.copyWith(fontSize: 34, fontStyle: FontStyle.italic)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text('&', style: TextStyle(fontSize: 20, color: secondaryColor, fontStyle: FontStyle.italic)),
        ),
        Text(invitation.groomName.isEmpty ? 'Groom' : invitation.groomName, style: titleStyle.copyWith(fontSize: 34, fontStyle: FontStyle.italic)),
        
        _buildCouplePhotos(invitation, secondaryColor, 'Floral'),
        
        const SizedBox(height: 8),
        Container(width: 40, height: 1.5, color: secondaryColor.withOpacity(0.5)),
        const SizedBox(height: 16),

        Text(dateString, style: titleStyle.copyWith(fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        Text(invitation.weddingTime, style: textContentStyle.copyWith(fontSize: 11), textAlign: TextAlign.center),
        const SizedBox(height: 16),

        Text(invitation.venueName.isEmpty ? 'The Garden Estate' : invitation.venueName, style: titleStyle.copyWith(fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        Text(invitation.venueAddress.isEmpty ? 'Lutyens Zone, New Delhi' : invitation.venueAddress, style: textContentStyle.copyWith(fontSize: 11), textAlign: TextAlign.center),
        const SizedBox(height: 12),

        if (invitation.personalMessage.isNotEmpty)
          Text('" ${invitation.personalMessage} "', style: textContentStyle.copyWith(fontStyle: FontStyle.italic, fontSize: 10), textAlign: TextAlign.center),
      ],
    );
  }

  // MODERN LAYOUT (Bold sans-serif headlines, structured grids, clean dividers)
  Widget _buildModernLayout(Color secondaryColor, TextStyle titleStyle, TextStyle bodyLabelStyle, TextStyle textContentStyle, String dateString, bool isDarkAccent) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: secondaryColor, width: 1.0),
          ),
          child: Text('THE WEDDING INVITATION', style: bodyLabelStyle.copyWith(fontSize: 8, letterSpacing: 1.5)),
        ),
        const SizedBox(height: 24),

        Text(invitation.brideName.isEmpty ? 'BRIDE' : invitation.brideName.toUpperCase(), style: titleStyle.copyWith(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text('+ JOINING HEARTS WITH +', style: bodyLabelStyle.copyWith(fontSize: 8, color: secondaryColor.withOpacity(0.6))),
        ),
        Text(invitation.groomName.isEmpty ? 'GROOM' : invitation.groomName.toUpperCase(), style: titleStyle.copyWith(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
        
        _buildCouplePhotos(invitation, secondaryColor, 'Modern'),
        
        const SizedBox(height: 16),
        Container(width: double.infinity, height: 1.5, color: secondaryColor),
        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TIMELINE', style: bodyLabelStyle.copyWith(fontSize: 8)),
                  const SizedBox(height: 4),
                  Text(dateString, style: textContentStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 10.5)),
                  Text(invitation.weddingTime, style: textContentStyle.copyWith(fontSize: 9.5)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LOCATION', style: bodyLabelStyle.copyWith(fontSize: 8)),
                  const SizedBox(height: 4),
                  Text(invitation.venueName.isEmpty ? 'Minimalist Art Space' : invitation.venueName, style: textContentStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 10.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(invitation.venueAddress.isEmpty ? 'New Delhi, India' : invitation.venueAddress, style: textContentStyle.copyWith(fontSize: 9.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (invitation.personalMessage.isNotEmpty)
          Text('" ${invitation.personalMessage} "', style: textContentStyle.copyWith(fontStyle: FontStyle.italic, fontSize: 9.5, height: 1.3)),
      ],
    );
  }
}

// -------------------------------------------------------------
// HELPER FOR COLLECTION CLASSIFICATION
// -------------------------------------------------------------
String _getCollectionForId(int id) {
  if ([1, 2, 4, 5, 6].contains(id)) return 'Royal';
  if ([7, 8, 9].contains(id)) return 'Luxury';
  if ([3, 10, 11, 12].contains(id)) return 'Floral';
  return 'Modern';
}

final Map<String, MemoryImage> _base64ImageCache = {};

MemoryImage getCachedMemoryImage(String base64StringOrDataUri) {
  return _base64ImageCache.putIfAbsent(base64StringOrDataUri, () {
    final base64Str = base64StringOrDataUri.startsWith('data:image') 
        ? base64StringOrDataUri.split(',').last 
        : base64StringOrDataUri;
    return MemoryImage(base64Decode(base64Str));
  });
}

// 1. Dotted Circle Painter for Royal
class DottedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dotCount;
  
  DottedCirclePainter({required this.color, this.strokeWidth = 1.2, this.dotCount = 36});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < dotCount; i++) {
      final angle = (i * 2 * math.pi) / dotCount;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 1.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DottedCirclePainter oldDelegate) => 
    oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth || oldDelegate.dotCount != dotCount;
}

// 2. Floral Wreath Painter for Floral
class FloralWreathPainter extends CustomPainter {
  final Color color;
  FloralWreathPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 + 2;

    // Draw the thin vine arc around the bottom half
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, math.pi * 0.15, math.pi * 0.7, false, paint);
    canvas.drawArc(rect, math.pi * 1.15, math.pi * 0.7, false, paint);

    // Draw small leaves along the vine
    final leafPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    for (double angle in [math.pi * 0.25, math.pi * 0.5, math.pi * 0.75,
                          math.pi * 1.25, math.pi * 1.5, math.pi * 1.75]) {
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle + math.pi / 4);
      canvas.drawOval(const Rect.fromLTWH(-1.5, -3, 3, 6), leafPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant FloralWreathPainter oldDelegate) => oldDelegate.color != color;
}

// -------------------------------------------------------------
// IMAGE RENDER HELPERS FOR COUPLE PHOTOS
// -------------------------------------------------------------
Widget _buildPhotoFrame(String url, {required Color borderColor, double size = 64, bool isCircular = true, String collection = ''}) {
  if (url.isEmpty) return const SizedBox.shrink();
  
  ImageProvider imageProvider;
  if (url.startsWith('data:image') || !url.startsWith('http')) {
    imageProvider = getCachedMemoryImage(url);
  } else {
    imageProvider = NetworkImage(url);
  }

  final Widget imageContainer = Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: isCircular ? null : BorderRadius.circular(8),
      border: Border.all(color: collection == 'Modern' ? Colors.transparent : borderColor, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
      image: DecorationImage(
        image: imageProvider,
        fit: BoxFit.cover,
      ),
    ),
  );

  if (collection == 'Royal') {
    // Royal dotted circular border
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: size + 8,
          height: size + 8,
          child: CustomPaint(
            painter: DottedCirclePainter(color: const Color(0xFFD4AF37)),
          ),
        ),
        imageContainer,
      ],
    );
  } else if (collection == 'Floral') {
    // Floral wreath border
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: size + 6,
          height: size + 6,
          child: CustomPaint(
            painter: FloralWreathPainter(color: borderColor),
          ),
        ),
        imageContainer,
      ],
    );
  } else if (collection == 'Luxury') {
    // Luxury asymmetric offset border
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 3,
          left: 3,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD4AF37), width: 1.0),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 3, bottom: 3),
          child: imageContainer,
        ),
      ],
    );
  } else if (collection == 'Modern') {
    // Modern interlocking thin double-gold line border
    return Stack(
      alignment: Alignment.center,
      children: [
        // Frame 1
        Container(
          width: size + 4,
          height: size + 4,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD4AF37), width: 0.8),
          ),
        ),
        // Frame 2
        Transform.rotate(
          angle: math.pi / 12, // 15 degrees
          child: Container(
            width: size + 4,
            height: size + 4,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.7), width: 0.8),
            ),
          ),
        ),
        imageContainer,
      ],
    );
  }

  return imageContainer;
}

Widget _buildCouplePhotos(InvitationModel invitation, Color accentColor, String collection) {
  final hasBride = invitation.brideImageUrl.isNotEmpty;
  final hasGroom = invitation.groomImageUrl.isNotEmpty;

  if (!hasBride && !hasGroom) return const SizedBox.shrink();

  final isCircular = collection == 'Royal' || collection == 'Floral';
  final frameBorderColor = collection == 'Royal' ? const Color(0xFFD4AF37) : accentColor;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (hasBride)
          _buildPhotoFrame(
            invitation.brideImageUrl,
            borderColor: frameBorderColor,
            isCircular: isCircular,
            collection: collection,
          ),
        if (hasBride && hasGroom) ...[
          const SizedBox(width: 8),
          Icon(Icons.favorite, color: frameBorderColor, size: 12),
          const SizedBox(width: 8),
        ],
        if (hasGroom)
          _buildPhotoFrame(
            invitation.groomImageUrl,
            borderColor: frameBorderColor,
            isCircular: isCircular,
            collection: collection,
          ),
      ],
    ),
  );
}

// -------------------------------------------------------------
// CUSTOM PAINTERS FOR PREMIUM ARCHES, LANTERNS, MANDAP, AND LOTUSES
// -------------------------------------------------------------

class MughalArchPainter extends CustomPainter {
  final Color archColor;
  final Color outerBgColor;
  
  MughalArchPainter({required this.archColor, required this.outerBgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double margin = 14.0;
    final double peakY = 80.0;
    final double baseY = 200.0;
    
    final fillPaint = Paint()
      ..color = outerBgColor
      ..style = PaintingStyle.fill;

    final archPath = Path();
    archPath.moveTo(margin, size.height - margin);
    archPath.lineTo(margin, baseY);
    
    // pointed scalloped arch left curve
    archPath.cubicTo(
      margin, baseY - 60,
      size.width * 0.25, peakY + 20,
      size.width / 2, peakY,
    );
    
    // pointed scalloped arch right curve
    archPath.cubicTo(
      size.width * 0.75, peakY + 20,
      size.width - margin, baseY - 60,
      size.width - margin, baseY,
    );
    
    archPath.lineTo(size.width - margin, size.height - margin);
    
    // Fill the outer header region above the arch
    final topCornersPath = Path();
    topCornersPath.moveTo(0, 0);
    topCornersPath.lineTo(size.width, 0);
    topCornersPath.lineTo(size.width, baseY);
    topCornersPath.lineTo(size.width - margin, baseY);
    topCornersPath.cubicTo(
      size.width - margin, baseY - 60,
      size.width * 0.75, peakY + 20,
      size.width / 2, peakY,
    );
    topCornersPath.cubicTo(
      size.width * 0.25, peakY + 20,
      margin, baseY - 60,
      margin, baseY,
    );
    topCornersPath.lineTo(0, baseY);
    topCornersPath.close();
    
    canvas.drawPath(topCornersPath, fillPaint);
    
    // Fill left, right and bottom margins outside the arch
    final sidePaint = Paint()
      ..color = outerBgColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, margin, size.height), sidePaint);
    canvas.drawRect(Rect.fromLTWH(size.width - margin, 0, margin, size.height), sidePaint);
    canvas.drawRect(Rect.fromLTWH(0, size.height - margin, size.width, margin), sidePaint);

    // Draw some gold decorative lines/patterns on the maroon top area (Image 3)
    final patternPaint = Paint()
      ..color = archColor.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(Offset(margin + 20, 40), 25, patternPaint);
    canvas.drawCircle(Offset(size.width - margin - 20, 40), 25, patternPaint);
    canvas.drawCircle(Offset(size.width / 2, 30), 20, patternPaint);

    // Draw main gold border
    final goldPaint = Paint()
      ..color = archColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(archPath, goldPaint);
    
    // Draw inner gold line
    final innerArchPath = Path();
    final double innerMargin = margin + 4;
    final double innerBaseY = baseY + 2;
    final double innerPeakY = peakY + 6;
    
    innerArchPath.moveTo(innerMargin, size.height - innerMargin);
    innerArchPath.lineTo(innerMargin, innerBaseY);
    innerArchPath.cubicTo(
      innerMargin, innerBaseY - 58,
      size.width * 0.25, innerPeakY + 18,
      size.width / 2, innerPeakY,
    );
    innerArchPath.cubicTo(
      size.width * 0.75, innerPeakY + 18,
      size.width - innerMargin, innerBaseY - 58,
      size.width - innerMargin, innerBaseY,
    );
    innerArchPath.lineTo(size.width - innerMargin, size.height - innerMargin);
    
    final innerGoldPaint = Paint()
      ..color = archColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(innerArchPath, innerGoldPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MughalLanternsPainter extends CustomPainter {
  final Color goldColor;
  
  MughalLanternsPainter({required this.goldColor});

  @override
  void paint(Canvas canvas, Size size) {
    final goldPaint = Paint()
      ..color = goldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
      
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD54F).withOpacity(0.65)
      ..style = PaintingStyle.fill;
      
    final brightGlowPaint = Paint()
      ..color = const Color(0xFFFFFDE7)
      ..style = PaintingStyle.fill;

    _drawLantern(canvas, Offset(size.width / 2, 80), 35, goldPaint, glowPaint, brightGlowPaint);
    _drawLantern(canvas, Offset(size.width * 0.24, 120), 20, goldPaint, glowPaint, brightGlowPaint);
    _drawLantern(canvas, Offset(size.width * 0.76, 120), 20, goldPaint, glowPaint, brightGlowPaint);
  }
  
  void _drawLantern(Canvas canvas, Offset attachPoint, double chainLength, Paint goldPaint, Paint glowPaint, Paint brightGlowPaint) {
    final double lanternTopY = attachPoint.dy + chainLength;
    
    canvas.drawLine(attachPoint, Offset(attachPoint.dx, lanternTopY), goldPaint);
    
    final capPath = Path();
    capPath.moveTo(attachPoint.dx - 8, lanternTopY);
    capPath.lineTo(attachPoint.dx + 8, lanternTopY);
    capPath.lineTo(attachPoint.dx + 5, lanternTopY - 4);
    capPath.lineTo(attachPoint.dx - 5, lanternTopY - 4);
    capPath.close();
    canvas.drawPath(capPath, goldPaint);
    
    final double glassHeight = 14;
    final glassRect = Rect.fromLTWH(attachPoint.dx - 6, lanternTopY, 12, glassHeight);
    canvas.drawOval(glassRect, goldPaint);
    
    canvas.drawCircle(Offset(attachPoint.dx, lanternTopY + glassHeight / 2), 5, glowPaint);
    canvas.drawCircle(Offset(attachPoint.dx, lanternTopY + glassHeight / 2), 2.5, brightGlowPaint);
    
    canvas.drawLine(Offset(attachPoint.dx - 8, lanternTopY + glassHeight), Offset(attachPoint.dx + 8, lanternTopY + glassHeight), goldPaint);
    
    final bottomPath = Path();
    bottomPath.moveTo(attachPoint.dx - 5, lanternTopY + glassHeight);
    bottomPath.lineTo(attachPoint.dx + 5, lanternTopY + glassHeight);
    bottomPath.lineTo(attachPoint.dx, lanternTopY + glassHeight + 6);
    bottomPath.close();
    canvas.drawPath(bottomPath, goldPaint);
    
    canvas.drawLine(Offset(attachPoint.dx, lanternTopY + glassHeight + 6), Offset(attachPoint.dx, lanternTopY + glassHeight + 14), goldPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PalaceMandapPainter extends CustomPainter {
  final Color color;
  
  PalaceMandapPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final double startY = size.height * 0.44;
    final double bottomY = size.height - 40;
    final double leftX = size.width * 0.15;
    final double rightX = size.width * 0.85;
    final double domePeakY = startY - 32;

    canvas.drawLine(Offset(leftX, startY), Offset(leftX, bottomY), paint);
    canvas.drawLine(Offset(leftX + 4, startY), Offset(leftX + 4, bottomY), paint);
    canvas.drawRect(Rect.fromLTRB(leftX - 4, bottomY - 10, leftX + 8, bottomY), paint);
    canvas.drawRect(Rect.fromLTRB(leftX - 2, startY, leftX + 6, startY + 8), paint);

    canvas.drawLine(Offset(rightX, startY), Offset(rightX, bottomY), paint);
    canvas.drawLine(Offset(rightX - 4, startY), Offset(rightX - 4, bottomY), paint);
    canvas.drawRect(Rect.fromLTRB(rightX - 8, bottomY - 10, rightX + 4, bottomY), paint);
    canvas.drawRect(Rect.fromLTRB(rightX - 6, startY, rightX + 2, startY + 8), paint);

    final domePath = Path();
    domePath.moveTo(leftX, startY);
    
    final midX = size.width / 2;
    domePath.cubicTo(
      leftX + 10, startY - 15,
      midX - 25, startY - 25,
      midX, domePeakY,
    );
    domePath.cubicTo(
      midX + 25, startY - 25,
      rightX - 10, startY - 15,
      rightX, startY,
    );
    
    canvas.drawPath(domePath, paint);

    final roofPath = Path();
    roofPath.moveTo(leftX - 6, startY);
    roofPath.lineTo(leftX - 2, startY - 8);
    
    roofPath.cubicTo(
      leftX + 15, startY - 25,
      midX - 35, domePeakY - 20,
      midX, domePeakY - 35,
    );
    roofPath.cubicTo(
      midX + 35, domePeakY - 20,
      rightX - 15, startY - 25,
      rightX + 2, startY - 8,
    );
    roofPath.lineTo(rightX + 6, startY);
    canvas.drawPath(roofPath, paint);
    
    canvas.drawLine(Offset(midX, domePeakY - 35), Offset(midX, domePeakY - 50), paint);
    canvas.drawCircle(Offset(midX, domePeakY - 42), 3, paint);
    canvas.drawCircle(Offset(midX, domePeakY - 48), 1.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LotusFlowerPainter extends CustomPainter {
  final Color lotusColor;
  
  LotusFlowerPainter({required this.lotusColor});

  @override
  void paint(Canvas canvas, Size size) {
    final petalFill = Paint()
      ..color = lotusColor.withOpacity(0.85)
      ..style = PaintingStyle.fill;
      
    final petalOutline = Paint()
      ..color = lotusColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
      
    final leafPaint = Paint()
      ..color = const Color(0xFF90A4AE).withOpacity(0.7)
      ..style = PaintingStyle.fill;

    _drawLotusGroup(canvas, Offset(size.width * 0.16, size.height - 50), petalFill, petalOutline, leafPaint);
    _drawLotusGroup(canvas, Offset(size.width * 0.84, size.height - 50), petalFill, petalOutline, leafPaint);
  }
  
  void _drawLotusGroup(Canvas canvas, Offset center, Paint fill, Paint outline, Paint leafPaint) {
    canvas.drawOval(Rect.fromCenter(center: center + const Offset(-18, 12), width: 32, height: 14), leafPaint);
    canvas.drawOval(Rect.fromCenter(center: center + const Offset(18, 12), width: 32, height: 14), leafPaint);
    
    _drawLotusFlower(canvas, center, fill, outline);
    _drawLotusFlower(canvas, center + const Offset(-22, 6), fill, outline, scale: 0.72);
    _drawLotusFlower(canvas, center + const Offset(22, 6), fill, outline, scale: 0.72);
  }
  
  void _drawLotusFlower(Canvas canvas, Offset pos, Paint fill, Paint outline, {double scale = 1.0}) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(scale);
    
    final centerPetal = Path()
      ..moveTo(0, 5)
      ..quadraticBezierTo(-7, -11, 0, -24)
      ..quadraticBezierTo(7, -11, 0, 5)
      ..close();
    canvas.drawPath(centerPetal, fill);
    canvas.drawPath(centerPetal, outline);
    
    final leftPetal1 = Path()
      ..moveTo(0, 5)
      ..quadraticBezierTo(-16, -6, -13, -18)
      ..quadraticBezierTo(-6, -9, 0, 5)
      ..close();
    canvas.drawPath(leftPetal1, fill);
    canvas.drawPath(leftPetal1, outline);

    final rightPetal1 = Path()
      ..moveTo(0, 5)
      ..quadraticBezierTo(16, -6, 13, -18)
      ..quadraticBezierTo(6, -9, 0, 5)
      ..close();
    canvas.drawPath(rightPetal1, fill);
    canvas.drawPath(rightPetal1, outline);

    final leftOuter = Path()
      ..moveTo(-5, 5)
      ..quadraticBezierTo(-24, 0, -20, -9)
      ..quadraticBezierTo(-11, -2, -5, 5)
      ..close();
    canvas.drawPath(leftOuter, fill);
    canvas.drawPath(leftOuter, outline);
    
    final rightOuter = Path()
      ..moveTo(5, 5)
      ..quadraticBezierTo(24, 0, 20, -9)
      ..quadraticBezierTo(11, -2, 5, 5)
      ..close();
    canvas.drawPath(rightOuter, fill);
    canvas.drawPath(rightOuter, outline);
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WavySideArchPainter extends CustomPainter {
  final Color maroonColor;
  final Color goldColor;
  
  WavySideArchPainter({required this.maroonColor, required this.goldColor});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = maroonColor
      ..style = PaintingStyle.fill;
      
    final goldPaint = Paint()
      ..color = goldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 1. Right Wavy Panel (Image 1)
    final rightPath = Path();
    rightPath.moveTo(size.width, 0);
    rightPath.lineTo(size.width * 0.72, 0);
    
    rightPath.cubicTo(
      size.width * 0.58, size.height * 0.25,
      size.width * 0.90, size.height * 0.45,
      size.width * 0.70, size.height * 0.70,
    );
    rightPath.cubicTo(
      size.width * 0.58, size.height * 0.82,
      size.width * 0.82, size.height * 0.92,
      size.width * 0.75, size.height,
    );
    rightPath.lineTo(size.width, size.height);
    rightPath.close();
    
    canvas.drawPath(rightPath, fillPaint);
    canvas.drawPath(rightPath, goldPaint);

    // 2. Bottom Left Corner Wave (Image 1)
    final leftPath = Path();
    leftPath.moveTo(0, size.height);
    leftPath.lineTo(0, size.height - 130);
    leftPath.quadraticBezierTo(size.width * 0.22, size.height - 90, size.width * 0.35, size.height);
    leftPath.close();
    
    canvas.drawPath(leftPath, fillPaint);
    canvas.drawPath(leftPath, goldPaint);

    // 3. Left vertical double border lines
    final borderPaint = Paint()
      ..color = maroonColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final goldBorderPaint = Paint()
      ..color = goldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
      
    canvas.drawLine(const Offset(16, 20), Offset(16, size.height - 150), borderPaint);
    canvas.drawLine(const Offset(20, 20), Offset(20, size.height - 158), goldBorderPaint);

    // Small foliage leaf patterns on left vertical lines
    final leafPaint = Paint()
      ..color = maroonColor.withOpacity(0.75)
      ..style = PaintingStyle.fill;
    for (double y = 40; y < size.height - 180; y += 40) {
      canvas.drawOval(Rect.fromLTWH(11, y, 5, 3), leafPaint);
      canvas.drawOval(Rect.fromLTWH(21, y + 20, 5, 3), leafPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TraditionalCoupleIllustrationPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;
  
  TraditionalCoupleIllustrationPainter({required this.primaryColor, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    // Rich Colored Traditional Couple Art style (Sherwani & Lehenga)
    final goldPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.fill;
    final crimsonPaint = Paint()
      ..color = const Color(0xFF8B0000)
      ..style = PaintingStyle.fill;
    final facePaint = Paint()
      ..color = const Color(0xFFFFD1A9)
      ..style = PaintingStyle.fill;
    final blackPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;

    // GROOM (Left side facing right)
    final groomBody = Path()
      ..moveTo(cx - 5, size.height)
      ..lineTo(cx - 35, size.height)
      ..quadraticBezierTo(cx - 30, cy + 18, cx - 22, cy + 10)
      ..lineTo(cx - 15, cy + 10)
      ..close();
    canvas.drawPath(groomBody, crimsonPaint);
    
    final groomShawl = Path()
      ..moveTo(cx - 18, cy + 10)
      ..lineTo(cx - 28, size.height)
      ..lineTo(cx - 22, size.height)
      ..lineTo(cx - 15, cy + 10)
      ..close();
    canvas.drawPath(groomShawl, goldPaint);

    canvas.drawOval(Rect.fromLTWH(cx - 24, cy - 2, 12, 14), facePaint);

    final turbanPath = Path()
      ..moveTo(cx - 26, cy - 2)
      ..cubicTo(cx - 32, cy - 14, cx - 12, cy - 18, cx - 12, cy - 6)
      ..quadraticBezierTo(cx - 18, cy - 2, cx - 26, cy - 2)
      ..close();
    canvas.drawPath(turbanPath, crimsonPaint);

    final turbanBand = Path()
      ..moveTo(cx - 26, cy - 2)
      ..lineTo(cx - 14, cy - 6)
      ..lineTo(cx - 15, cy - 10)
      ..lineTo(cx - 27, cy - 5)
      ..close();
    canvas.drawPath(turbanBand, goldPaint);
    
    final kalgi = Path()
      ..moveTo(cx - 22, cy - 12)
      ..quadraticBezierTo(cx - 26, cy - 20, cx - 22, cy - 22)
      ..quadraticBezierTo(cx - 18, cy - 16, cx - 22, cy - 12);
    canvas.drawPath(kalgi, goldPaint);

    // BRIDE (Right side facing left)
    final brideBody = Path()
      ..moveTo(cx + 5, size.height)
      ..lineTo(cx + 35, size.height)
      ..quadraticBezierTo(cx + 30, cy + 18, cx + 22, cy + 10)
      ..lineTo(cx + 15, cy + 10)
      ..close();
    canvas.drawPath(brideBody, crimsonPaint);

    final brideGold = Path()
      ..moveTo(cx + 18, cy + 10)
      ..lineTo(cx + 28, size.height)
      ..lineTo(cx + 32, size.height)
      ..lineTo(cx + 20, cy + 10)
      ..close();
    canvas.drawPath(brideGold, goldPaint);

    canvas.drawOval(Rect.fromLTWH(cx + 12, cy - 2, 12, 14), facePaint);
    canvas.drawArc(Rect.fromLTWH(cx + 12, cy - 4, 10, 8), math.pi, math.pi, true, blackPaint);

    final dupatta = Path()
      ..moveTo(cx + 11, cy - 2)
      ..cubicTo(cx + 12, cy - 16, cx + 26, cy - 14, cx + 25, cy - 2)
      ..quadraticBezierTo(cx + 28, cy + 12, cx + 32, cy + 24)
      ..lineTo(cx + 24, cy + 24)
      ..close();
    canvas.drawPath(dupatta, crimsonPaint);
    
    final dupattaBorder = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(dupatta, dupattaBorder);

    canvas.drawCircle(Offset(cx + 18, cy - 3), 1.0, goldPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -------------------------------------------------------------
// HEX COLOR STRING PARSER EXTENSION
// -------------------------------------------------------------
extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
