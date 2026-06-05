import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType keyboardType;
  final int? maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final textColor = isLight ? AppColors.primaryText : Colors.white;
    final hintColor = isLight ? AppColors.secondaryText.withOpacity(0.6) : Colors.white24;
    final activeGold = isLight ? const Color(0xFF2563EB) : AppColors.navyAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: (isLight ? AppColors.secondaryText : AppColors.navyAccent).withOpacity(0.85),
          ),
        ),
        const SizedBox(height: 8),
        // TextField
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          style: GoogleFonts.inter(
            color: textColor,
            fontSize: 13,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
              color: hintColor,
              fontSize: 13,
            ),
            filled: true,
            fillColor: isLight ? AppColors.inputFill : const Color(0xFF131A2A),
            prefixIcon: prefixIcon != null 
                ? Icon(prefixIcon, color: activeGold.withOpacity(0.7), size: 18) 
                : null,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: AppDesign.borderSmall,
              borderSide: BorderSide(color: isLight ? AppColors.border : Colors.white.withOpacity(0.04)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppDesign.borderSmall,
              borderSide: BorderSide(color: isLight ? AppColors.border : Colors.white.withOpacity(0.04)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppDesign.borderSmall,
              borderSide: BorderSide(color: activeGold, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppDesign.borderSmall,
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppDesign.borderSmall,
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
