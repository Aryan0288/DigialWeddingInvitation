import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'app_text.dart';

class AppLoading extends StatelessWidget {
  final String message;

  const AppLoading({
    super.key,
    this.message = 'Loading invitation data...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Elegant Circular Progress with gold gradient colors
          const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              color: AppColors.navyAccent,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          AppBody(
            message,
            color: Colors.white54,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}
