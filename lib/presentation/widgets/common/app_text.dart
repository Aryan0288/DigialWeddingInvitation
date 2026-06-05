import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class AppText extends StatelessWidget {
  final String text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;
  final FontStyle? fontStyle;
  final double? height;
  final double? letterSpacing;
  final bool isSerif;
  final bool preventTranslation;

  const AppText(
    this.text, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
    this.fontStyle,
    this.height,
    this.letterSpacing,
    this.isSerif = false,
    this.preventTranslation = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    
    Color? resolvedColor = color;
    if (resolvedColor != null) {
      if (isLight && !preventTranslation) {
        if (resolvedColor == Colors.white) {
          resolvedColor = AppColors.primaryText;
        } else if (resolvedColor == Colors.white70) {
          resolvedColor = AppColors.primaryText.withOpacity(0.7);
        } else if (resolvedColor == Colors.white60) {
          resolvedColor = AppColors.primaryText.withOpacity(0.6);
        } else if (resolvedColor == Colors.white54) {
          resolvedColor = AppColors.primaryText.withOpacity(0.54);
        } else if (resolvedColor == Colors.white38) {
          resolvedColor = AppColors.primaryText.withOpacity(0.38);
        } else if (resolvedColor == Colors.white30) {
          resolvedColor = AppColors.primaryText.withOpacity(0.3);
        } else if (resolvedColor == Colors.white24) {
          resolvedColor = AppColors.primaryText.withOpacity(0.24);
        } else if (resolvedColor == Colors.white12) {
          resolvedColor = AppColors.primaryText.withOpacity(0.12);
        } else if (resolvedColor == Colors.white10) {
          resolvedColor = AppColors.primaryText.withOpacity(0.10);
        }
      }
    } else {
      resolvedColor = isLight ? AppColors.primaryText : Colors.white;
    }

    // Standardizes typography configuration: Cormorant Garamond for Serifs, Inter for Sans-Serifs
    TextStyle baseStyle = isSerif
        ? GoogleFonts.playfairDisplay(textStyle: TextStyle(color: resolvedColor))
        : GoogleFonts.inter(textStyle: TextStyle(color: resolvedColor));
        
    final finalStyle = baseStyle.merge(style).copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: height,
      letterSpacing: letterSpacing,
    );

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: finalStyle,
    );
  }
}

class AppDisplay extends AppText {
  const AppDisplay(
    super.text, {
    super.key,
    super.color,
    super.fontSize = 42,
    super.fontWeight = FontWeight.w300,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.isSerif = true,
    super.letterSpacing,
    super.fontStyle,
    super.preventTranslation,
  });
}

class AppTitle extends AppText {
  const AppTitle(
    super.text, {
    super.key,
    super.color,
    super.fontSize = 26,
    super.fontWeight = FontWeight.bold,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.isSerif = true,
    super.letterSpacing,
    super.fontStyle,
    super.preventTranslation,
  });
}

class AppHeading extends AppText {
  const AppHeading(
    super.text, {
    super.key,
    super.color,
    super.fontSize = 18,
    super.fontWeight = FontWeight.w600,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.isSerif = false,
    super.letterSpacing,
    super.fontStyle,
    super.preventTranslation,
  });
}

class AppBody extends AppText {
  const AppBody(
    super.text, {
    super.key,
    super.color,
    super.fontSize = 13,
    super.fontWeight = FontWeight.normal,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.height = 1.5,
    super.isSerif = false,
    super.letterSpacing,
    super.fontStyle,
    super.preventTranslation,
  });
}

class AppCaption extends AppText {
  const AppCaption(
    super.text, {
    super.key,
    super.color,
    super.fontSize = 11,
    super.fontWeight = FontWeight.normal,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.isSerif = false,
    super.letterSpacing,
    super.fontStyle,
    super.preventTranslation,
  });
}

class AppLabel extends AppText {
  const AppLabel(
    super.text, {
    super.key,
    super.color,
    super.fontSize = 11,
    super.fontWeight = FontWeight.w600,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.isSerif = false,
    super.letterSpacing = 1.0,
    super.fontStyle,
    super.preventTranslation,
  });
}
