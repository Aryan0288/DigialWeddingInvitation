import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/invitation_model.dart';
import '../../data/models/remote_template_model.dart';

// Central Factory
class InvitationTemplateFactory {
  static Widget getTemplate({
    required int templateId,
    required InvitationModel invitation,
    bool isPreview = true,
    List<RemoteTemplateModel> availableTemplates = const [],
  }) {
    if (templateId > 3 && availableTemplates.any((t) => t.id == templateId)) {
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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

    final TextStyle titleStyle = GoogleFonts.getFont(
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

    final TextStyle bodyLabelStyle = GoogleFonts.getFont(
      templateSpec.fontBody,
      textStyle: TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.bold,
        color: secondaryColor.withOpacity(0.8),
        letterSpacing: 3.0,
      ),
    );

    final TextStyle textContentStyle = GoogleFonts.getFont(
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
