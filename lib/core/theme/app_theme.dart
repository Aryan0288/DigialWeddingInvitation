import 'package:flutter/material.dart';

class AppColors {
  // Centralized professional color palettes (SaaS/Luxury Wedding)

  // 1. Royal Navy Gold (Mapped to Light SaaS App Theme)
  static const Color navyBackground = Color(0xFFFFFFFF); // App background
  static const Color navySurface = Color(0xFFFAFAFA);    // Section background / sidebars
  static const Color navyPrimary = Color(0xFF111827);    // Primary text
  static const Color navyAccent = Color(0xFFC8A96A);     // Accent gold

  // 2. Ivory Gold (For card templates only)
  static const Color ivoryBackground = Color(0xFFF8F5F0);
  static const Color ivorySurface = Color(0xFFFFFFFF);
  static const Color ivoryPrimary = Color(0xFF1F1F1F);
  static const Color ivoryAccent = Color(0xFFC8A96A);
  
  // 3. Emerald Luxury (For card templates only)
  static const Color emeraldBackground = Color(0xFF0F3D3E);
  static const Color emeraldSurface = Color(0xFF174D4E);
  static const Color emeraldPrimary = Color(0xFFF7F4EA);
  static const Color emeraldAccent = Color(0xFFD4AF37);

  // Common UI helper colors (SaaS Light Theme)
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color inputFill = Color(0xFFFFFFFF); // Clean white fields
  static const Color border = Color(0xFFE8E2D8);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF4E8F5B); // Soft wedding green

  // Dedicated design system color tokens
  static const Color background = Color(0xFFF5F1EB);
  static const Color sectionBackground = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primaryText = Color(0xFF2D2A26);
  static const Color secondaryText = Color(0xFF6B645C);
  static const Color mutedText = Color(0xFF8C847A);
  static const Color accentGold = Color(0xFFf1c232); // Premium Warm Gold
  static const Color hoverGold = Color(0xFF755731);  // Deep gold/bronze
  // static const Color accent = Color(0xFF8B6B3D); 
  static const Color accent = Color(0xFFf1c232); 
      
}


class AppDesign {
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusRound = 30.0;
  
  static BorderRadius borderSmall = BorderRadius.circular(radiusSmall);
  static BorderRadius borderMedium = BorderRadius.circular(radiusMedium);
  static BorderRadius borderLarge = BorderRadius.circular(radiusLarge);
  static BorderRadius borderRound = BorderRadius.circular(radiusRound);

  // Spacing (Margins / Paddings)
  static const double spaceXS = 4.0;
  static const double spaceSmall = 8.0;
  static const double spaceMedium = 16.0;
  static const double spaceLarge = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // Shadows
  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.06),
      blurRadius: 16,
      spreadRadius: 2,
    )
  ];
  
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A2D2A26),
      blurRadius: 12,
      offset: Offset(0, 4),
    )
  ];

  static const List<BoxShadow> premiumShadow = [
    BoxShadow(
      color: Color(0x0F2D2A26),
      blurRadius: 24,
      offset: Offset(0, 8),
    )
  ];

  // Animation Timings
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationMedium = Duration(milliseconds: 400);
  static const Duration durationSlow = Duration(milliseconds: 800);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.sectionBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primaryText),
        titleTextStyle: TextStyle(
          color: AppColors.primaryText,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: AppDesign.borderMedium,
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
    );
  }
}
