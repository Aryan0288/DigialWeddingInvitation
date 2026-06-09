import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/invitation_model.dart';
import 'painters/template_painters.dart';

// File-level static DateFormat caches to avoid repeated creation in build methods
final DateFormat _weddingDateFormatLong = DateFormat('EEEE, MMMM d, y');
final DateFormat _weddingDateFormatShort = DateFormat('MMMM d, y');

String formatWeddingDateLong(DateTime date, {bool useStub = false}) {
  if (useStub) return 'Sunday, October 18, 2026';
  return _weddingDateFormatLong.format(date);
}

String formatWeddingDateShort(DateTime date, {bool useStub = false}) {
  if (useStub) return 'October 18, 2026';
  return _weddingDateFormatShort.format(date);
}

// Caches AssetImage objects as static constants to prevent repeated object creation
class AppAssetImages {
  static const String cardDesign1 = 'lib/assests/png/card_design_1.png';
  static const String design2 = 'lib/assests/png/design-2.jpg';
  static const String design3 = 'lib/assests/png/design-3.jpg';
  static const String design4 = 'lib/assests/png/design-4.jpg';
  static const String design5 = 'lib/assests/png/design-5.png';
  static const String design6 = 'lib/assests/png/design-6.png';
  static const String design7 = 'lib/assests/png/design-7.png';
  static const String design8 = 'lib/assests/png/design-8.png';
  static const String design9 = 'lib/assests/png/design-9.png';

  static const Map<String, AssetImage> cachedImages = {
    cardDesign1: AssetImage(cardDesign1),
    design2: AssetImage(design2),
    design3: AssetImage(design3),
    design4: AssetImage(design4),
    design5: AssetImage(design5),
    design6: AssetImage(design6),
    design7: AssetImage(design7),
    design8: AssetImage(design8),
    design9: AssetImage(design9),
  };

  static AssetImage get(String path) {
    return cachedImages[path] ?? AssetImage(path);
  }
}

// Standardized premium background decoration widget
class DesignBackground extends StatelessWidget {
  final String? topAsset;
  final String? bottomAsset;
  final String? bgPatternAsset;
  final double opacity;
  final double scale;
  final Widget child;
  final Color? backgroundColor;
  final List<Color>? backgroundGradient;
  final double bgPatternOpacity;

  const DesignBackground({
    super.key,
    this.topAsset,
    this.bottomAsset,
    this.bgPatternAsset,
    this.opacity = 1.0,
    this.scale = 1.0,
    required this.child,
    this.backgroundColor,
    this.backgroundGradient,
    this.bgPatternOpacity = 0.05,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: backgroundGradient != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: backgroundGradient!,
              )
            : null,
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Background pattern layer if provided
          if (bgPatternAsset != null)
            Positioned.fill(
              child: Opacity(
                opacity: bgPatternOpacity,
                child: Image(
                  image: AppAssetImages.get(bgPatternAsset!),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          
          if (topAsset != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.topCenter,
                child: Opacity(
                  opacity: opacity,
                  child: Image(
                    image: AppAssetImages.get(topAsset!),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            
          if (bottomAsset != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.bottomCenter,
                child: Opacity(
                  opacity: opacity,
                  child: Image(
                    image: AppAssetImages.get(bottomAsset!),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            
          Positioned.fill(
            child: child,
          ),
        ],
      ),
    );
  }
}

// Optimized caching layer for GoogleFonts to prevent factory call overhead during scrolling.
class TemplateFontCache {
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

String getCollectionForId(int id) {
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

class PhotoFrameWidget extends StatelessWidget {
  final String url;
  final Color borderColor;
  final double size;
  final bool isCircular;
  final String collection;
  final bool isPreview;

  const PhotoFrameWidget({
    super.key,
    required this.url,
    required this.borderColor,
    this.size = 64,
    this.isCircular = true,
    this.collection = '',
    this.isPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const SizedBox.shrink();
    
    ImageProvider imageProvider;
    if (url.startsWith('data:image') || !url.startsWith('http')) {
      imageProvider = getCachedMemoryImage(url);
    } else {
      imageProvider = CachedNetworkImageProvider(url);
    }

    // Downscale image inside showcase grid preview to improve memory usage & scroll performance
    final ImageProvider finalImageProvider = isPreview
        ? ResizeImage(imageProvider, width: 128, height: 128)
        : imageProvider;

    final Widget imageContainer = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircular ? null : BorderRadius.circular(8),
        border: Border.all(color: collection == 'Modern' ? Colors.transparent : borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        image: DecorationImage(
          image: finalImageProvider,
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
            child: const CustomPaint(
              painter: DottedCirclePainter(color: Color(0xFFD4AF37)),
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
                border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.7), width: 0.8),
              ),
            ),
          ),
          imageContainer,
        ],
      );
    }

    return imageContainer;
  }
}

class CouplePhotosWidget extends StatelessWidget {
  final InvitationModel invitation;
  final Color accentColor;
  final String collection;
  final bool isPreview;

  const CouplePhotosWidget({
    super.key,
    required this.invitation,
    required this.accentColor,
    required this.collection,
    this.isPreview = false,
  });

  @override
  Widget build(BuildContext context) {
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
            PhotoFrameWidget(
              url: invitation.brideImageUrl,
              borderColor: frameBorderColor,
              isCircular: isCircular,
              collection: collection,
              isPreview: isPreview,
            ),
          if (hasBride && hasGroom) ...[
            const SizedBox(width: 8),
            Icon(Icons.favorite, color: frameBorderColor, size: 12),
            const SizedBox(width: 8),
          ],
          if (hasGroom)
            PhotoFrameWidget(
              url: invitation.groomImageUrl,
              borderColor: frameBorderColor,
              isCircular: isCircular,
              collection: collection,
              isPreview: isPreview,
            ),
        ],
      ),
    );
  }
}

class CoupleFrameOrIllustrationWidget extends StatelessWidget {
  final InvitationModel invitation;
  final Color accentColor;
  final String frameStyle;
  final bool isPreview;

  const CoupleFrameOrIllustrationWidget({
    super.key,
    required this.invitation,
    required this.accentColor,
    required this.frameStyle,
    this.isPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasBride = invitation.brideImageUrl.isNotEmpty;
    final hasGroom = invitation.groomImageUrl.isNotEmpty;

    if (hasBride || hasGroom) {
      const double size = 50.0;
      ImageProvider rawBrideProvider = invitation.brideImageUrl.startsWith('data:image') || !invitation.brideImageUrl.startsWith('http')
          ? getCachedMemoryImage(invitation.brideImageUrl)
          : NetworkImage(invitation.brideImageUrl) as ImageProvider;
          
      ImageProvider rawGroomProvider = invitation.groomImageUrl.startsWith('data:image') || !invitation.groomImageUrl.startsWith('http')
          ? getCachedMemoryImage(invitation.groomImageUrl)
          : NetworkImage(invitation.groomImageUrl) as ImageProvider;

      final ImageProvider brideProvider = isPreview
          ? ResizeImage(rawBrideProvider, width: 128, height: 128)
          : rawBrideProvider;

      final ImageProvider groomProvider = isPreview
          ? ResizeImage(rawGroomProvider, width: 128, height: 128)
          : rawGroomProvider;

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
                color: Colors.black.withValues(alpha: 0.15),
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
          primaryColor: accentColor.withValues(alpha: 0.15),
          accentColor: accentColor,
        ),
      );
    }
  }
}

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

