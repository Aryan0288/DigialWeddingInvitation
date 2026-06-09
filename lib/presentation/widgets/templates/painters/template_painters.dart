import 'dart:math' as math;
import 'package:flutter/material.dart';

// 1. Intricate Circular Mandala
class MandalaPainter extends CustomPainter {
  final Color color;
  const MandalaPainter({required this.color});

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
  const PeacockFeatherPainter({this.isRotated = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (isRotated) {
      canvas.translate(size.width, size.height);
      canvas.rotate(math.pi);
    }

    final goldPaint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final tealPaint = Paint()
      ..color = const Color(0xFF00ADB5).withValues(alpha: 0.15)
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
  const FloralCornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB76E79).withValues(alpha: 0.4)
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
      ..color = const Color(0xFFB76E79).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(15, 15), 4, bulbPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 4. Vector Painter for Dynamic Card Corners
class GoldCornerPainter extends CustomPainter {
  final Color color;
  const GoldCornerPainter({required this.color});

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

// 5. Dotted Circle Painter for Royal
class DottedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dotCount;
  
  const DottedCirclePainter({required this.color, this.strokeWidth = 1.2, this.dotCount = 36});

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

// 6. Floral Wreath Painter for Floral
class FloralWreathPainter extends CustomPainter {
  final Color color;
  const FloralWreathPainter({required this.color});

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

// 7. Mughal Arch Painter
class MughalArchPainter extends CustomPainter {
  final Color archColor;
  final Color outerBgColor;
  
  const MughalArchPainter({required this.archColor, required this.outerBgColor});

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
      ..color = archColor.withValues(alpha: 0.2)
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
      ..color = archColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(innerArchPath, innerGoldPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 8. Mughal Lanterns Painter
class MughalLanternsPainter extends CustomPainter {
  final Color goldColor;
  
  const MughalLanternsPainter({required this.goldColor});

  @override
  void paint(Canvas canvas, Size size) {
    final goldPaint = Paint()
      ..color = goldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
      
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.65)
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

// 9. Palace Mandap Painter
class PalaceMandapPainter extends CustomPainter {
  final Color color;
  
  const PalaceMandapPainter({required this.color});

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

// 10. Lotus Flower Painter
class LotusFlowerPainter extends CustomPainter {
  final Color lotusColor;
  
  const LotusFlowerPainter({required this.lotusColor});

  @override
  void paint(Canvas canvas, Size size) {
    final petalFill = Paint()
      ..color = lotusColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
      
    final petalOutline = Paint()
      ..color = lotusColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
      
    final leafPaint = Paint()
      ..color = const Color(0xFF90A4AE).withValues(alpha: 0.7)
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

// 11. Wavy Side Arch Painter
class WavySideArchPainter extends CustomPainter {
  final Color maroonColor;
  final Color goldColor;
  
  const WavySideArchPainter({required this.maroonColor, required this.goldColor});

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
      ..color = maroonColor.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;
    for (double y = 40; y < size.height - 180; y += 40) {
      canvas.drawOval(Rect.fromLTWH(11, y, 5, 3), leafPaint);
      canvas.drawOval(Rect.fromLTWH(21, y + 20, 5, 3), leafPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 12. Traditional Couple Illustration Painter
class TraditionalCoupleIllustrationPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;
  
  const TraditionalCoupleIllustrationPainter({required this.primaryColor, required this.accentColor});

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
