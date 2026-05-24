import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    if (templateId == 4) {
      final RemoteTemplateModel templateSpec = availableTemplates.firstWhere(
        (t) => t.id == 4,
        orElse: () => RemoteTemplateModel(
          id: 4,
          title: 'Jaipur Palace (Emerald & Imperial Gold)',
          description: 'Dynamic Remote Theme: Royal Jaipur emerald green coupled with imperial gold mandalas and borders.',
          primaryColorHex: '#004B49',
          secondaryColorHex: '#F1C40F',
          bgGradientHex: ['#003332', '#004B49', '#001A19'],
          bgPatternUrl: 'https://images.unsplash.com/photo-1621510456681-23a23cfb5f57?q=80&w=2000',
          dividerIconUrl: 'https://cdn-icons-png.flaticon.com/512/2913/2913604.png',
          borderFrameUrl: 'https://cdn-icons-png.flaticon.com/512/10700/10700940.png',
          fontTitle: 'Cinzel',
          fontBody: 'Montserrat',
        ),
      );
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

    return Container(
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
          Padding(
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
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                        const SizedBox(height: 28),
                        
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
        ],
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

    return Container(
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
          Padding(
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
                        const SizedBox(height: 28),

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
        ],
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

    return Container(
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
          Padding(
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
                    const SizedBox(height: 28),

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
        ],
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

    // 1. Decodes Hex Color strings safely
    final Color primaryColor = HexColor.fromHex(templateSpec.primaryColorHex);
    final Color secondaryColor = HexColor.fromHex(templateSpec.secondaryColorHex);
    final List<Color> gradientColors = templateSpec.bgGradientHex
        .map((hex) => HexColor.fromHex(hex))
        .toList();

    // 2. Fetch Google Fonts dynamically at runtime
    final TextStyle titleStyle = GoogleFonts.getFont(
      templateSpec.fontTitle,
      textStyle: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w300,
        color: secondaryColor,
        letterSpacing: 1.0,
      ),
    );

    final TextStyle bodyLabelStyle = GoogleFonts.getFont(
      templateSpec.fontBody,
      textStyle: TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.bold,
        color: secondaryColor.withOpacity(0.8),
        letterSpacing: 2.5,
      ),
    );

    return Container(
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
          // 3. Load dynamic network background pattern with safe fallback
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

          // 4. Elegant thin double gold border frame
          Padding(
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        // 5. Dynamic Remote Corner/Icon vector
                        CachedNetworkImage(
                          imageUrl: templateSpec.dividerIconUrl,
                          width: 36,
                          height: 36,
                          color: secondaryColor,
                          placeholder: (context, url) => const SizedBox.shrink(),
                          errorWidget: (context, url, error) => Icon(
                            Icons.favorite_border_rounded, 
                            color: secondaryColor, 
                            size: 24
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'SHUBH VIVAH INVITATION',
                          style: bodyLabelStyle,
                        ),
                        const SizedBox(height: 24),

                        // Couple names
                        Text(
                          invitation.brideName.isEmpty ? 'Bride' : invitation.brideName,
                          style: titleStyle,
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Text(
                            'weds',
                            style: TextStyle(
                              fontFamily: 'Serif',
                              fontStyle: FontStyle.italic,
                              fontSize: 20,
                              color: secondaryColor,
                            ),
                          ),
                        ),
                        Text(
                          invitation.groomName.isEmpty ? 'Groom' : invitation.groomName,
                          style: titleStyle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),

                        Container(
                          width: 60,
                          height: 1.5,
                          color: secondaryColor,
                        ),
                        const SizedBox(height: 28),

                        // Logistics Schedule
                        Text(
                          'JOIN US ON',
                          style: bodyLabelStyle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dateString.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: secondaryColor == const Color(0xFF4A3437) ? const Color(0xFF4A3437) : const Color(0xFFF9F6F0),
                            letterSpacing: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          invitation.weddingTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryColor == const Color(0xFF4A3437) ? const Color(0xFF7A5C61) : Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Venue
                        Text(
                          'EVENT VENUE',
                          style: bodyLabelStyle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          invitation.venueName.isEmpty ? 'The Grand Palace Resort' : invitation.venueName,
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: secondaryColor == const Color(0xFF4A3437) ? const Color(0xFF4A3437) : const Color(0xFFF9F6F0),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          invitation.venueAddress.isEmpty ? 'Main Palace Road, New Delhi' : invitation.venueAddress,
                          style: TextStyle(
                            fontSize: 11,
                            color: secondaryColor == const Color(0xFF4A3437) ? const Color(0xFF7A5C61) : Colors.white60,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),

                        // Personal Message
                        if (invitation.personalMessage.isNotEmpty)
                          Text(
                            '" ${invitation.personalMessage} "',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 11,
                              color: secondaryColor == const Color(0xFF4A3437) ? const Color(0xFF9E7E83) : Colors.white54,
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
        ],
      ),
    );
  }
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
