import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/invitation_model.dart';
import '../../../widgets/templates_widgets.dart';
import '../../../widgets/common/app_text.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/scroll_entrance.dart';

// Stub invitation data for mockup previews
final _stubInvitation = InvitationModel(
  id: 'stub',
  brideName: 'Devika',
  groomName: 'Rohan',
  weddingDate: DateTime.now().add(const Duration(days: 60)),
  weddingTime: '18:30',
  venueName: 'Grand Palace Hall',
  venueAddress: 'Main Palace Road, New Delhi',
  personalMessage: 'Love sparkles & celebrations await!',
  selectedTemplateId: 1,
);

final _dummyInvitation = InvitationModel(
  id: 'dummy',
  brideName: 'Kareena',
  groomName: 'Saif',
  weddingDate: DateTime.now().add(const Duration(days: 90)),
  weddingTime: '19:00',
  venueName: 'The Taj Mahal Palace',
  venueAddress: 'Colaba, Mumbai, India',
  personalMessage: 'We request the honor of your presence.',
  selectedTemplateId: 4,
);

class LandingHeroSection extends StatelessWidget {
  const LandingHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (isMobile) {
      return ScrollEntrance(
        type: ScrollEntranceType.slideUp,
        delayIndex: 1,
        triggerOnScroll: false,
        child: Column(
          children: [
            const SizedBox(height: 24),
            const AppText(
              'ELEGANT & SELF-SERVICE PLATFORM',
              fontSize: 11,
              letterSpacing: 4.0,
              fontWeight: FontWeight.w600,
              color: AppColors.navyAccent,
            ),
            const SizedBox(height: 16),
            HeroTitleText(isMobile: isMobile, isLight: isLight),
            const SizedBox(height: 16),
            HeroDescriptionText(isMobile: isMobile, isLight: isLight),
            const SizedBox(height: 32),
            const HeroCtaButton(),
            const SizedBox(height: 48),
            _buildHeroCardStack(),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: ScrollEntrance(
            type: ScrollEntranceType.slideUp,
            delayIndex: 1,
            triggerOnScroll: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  'ELEGANT & SELF-SERVICE PLATFORM',
                  fontSize: 11,
                  letterSpacing: 4.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navyAccent,
                ),
                const SizedBox(height: 20),
                HeroTitleText(isMobile: isMobile, isLight: isLight),
                const SizedBox(height: 20),
                Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: HeroDescriptionText(isMobile: isMobile, isLight: isLight),
                ),
                const SizedBox(height: 36),
                const HeroCtaButton(),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: ScrollEntrance(
            type: ScrollEntranceType.scaleIn,
            delayIndex: 3,
            triggerOnScroll: false,
            child: Center(
              child: _buildHeroCardStack(),
            ),
          ),
        ),
      ],
    );
  }

  // Pre-cached hero card widgets — built once, never rebuilt during scroll
  static final Widget _heroCard1 = _buildStackCardWrapper(
    width: _cardWidth,
    height: _cardHeight,
    child: RoseGoldFloralTemplate(
      uiModel: TemplateUIModel.build(_stubInvitation, 3, const []),
      isPreview: true,
    ),
  );
  static final Widget _heroCard2 = _buildStackCardWrapper(
    width: _cardWidth,
    height: _cardHeight,
    child: MughalVintageArchTemplate(
      uiModel: TemplateUIModel.build(_dummyInvitation, 4, const []),
      isPreview: true,
    ),
  );
  static final Widget _heroCard3 = _buildStackCardWrapper(
    width: _cardWidth,
    height: _cardHeight,
    child: GoldRedMandalaTemplate(
      uiModel: TemplateUIModel.build(_stubInvitation, 1, const []),
      isPreview: true,
    ),
  );

  static const double _cardWidth = 240;
  static const double _cardHeight = 426;

  Widget _buildHeroCardStack() {
    return SizedBox(
      height: 480,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform(
            transform: Matrix4.identity()
              ..translate(-50.0, 10.0, 0.0)
              ..rotateZ(-0.15),
            origin: const Offset(120, 213),
            child: _heroCard1,
          ),
          Transform(
            transform: Matrix4.identity()
              ..translate(50.0, 20.0, 0.0)
              ..rotateZ(0.15),
            origin: const Offset(120, 213),
            child: _heroCard2,
          ),
          Transform(
            transform: Matrix4.identity()
              ..translate(0.0, -10.0, 0.0),
            child: _heroCard3,
          ),
        ],
      ),
    );
  }

  static Widget _buildStackCardWrapper({required double width, required double height, required Widget child}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.55),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 360,
          height: 640,
          child: RepaintBoundary(
            child: child,
          ),
        ),
      ),
    );
  }
}

class HeroTitleText extends StatelessWidget {
  final bool isMobile;
  final bool isLight;

  const HeroTitleText({
    super.key,
    required this.isMobile,
    required this.isLight,
  });

  // Pre-cached Playfair TextStyles (Strategy B)
  static final TextStyle _playfairMobileLight = GoogleFonts.playfairDisplay(
    fontSize: 36,
    fontWeight: FontWeight.w300,
    color: AppColors.primaryText,
    height: 1.25,
  );
  static final TextStyle _playfairMobileDark = GoogleFonts.playfairDisplay(
    fontSize: 36,
    fontWeight: FontWeight.w300,
    color: Colors.white,
    height: 1.25,
  );
  static final TextStyle _playfairDesktopLight = GoogleFonts.playfairDisplay(
    fontSize: 56,
    fontWeight: FontWeight.w300,
    color: AppColors.primaryText,
    height: 1.25,
  );
  static final TextStyle _playfairDesktopDark = GoogleFonts.playfairDisplay(
    fontSize: 56,
    fontWeight: FontWeight.w300,
    color: Colors.white,
    height: 1.25,
  );

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle = isMobile
        ? (isLight ? _playfairMobileLight : _playfairMobileDark)
        : (isLight ? _playfairDesktopLight : _playfairDesktopDark);

    return RichText(
      textAlign: isMobile ? TextAlign.center : TextAlign.start,
      text: TextSpan(
        style: baseStyle,
        children: const [
          TextSpan(text: 'Craft Elegant\nDigital '),
          TextSpan(
            text: 'Wedding Cards',
            style: TextStyle(
              color: AppColors.accentGold,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class HeroDescriptionText extends StatelessWidget {
  final bool isMobile;
  final bool isLight;

  const HeroDescriptionText({
    super.key,
    required this.isMobile,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    return AppBody(
      'Design luxury interactive invitations in minutes. Choose from our premium collections, customize detail fields, generate live links with real-time RSVP dashboards, and share high-resolution downloads with your guests.',
      color: isLight ? AppColors.secondaryText : Colors.white60,
      textAlign: isMobile ? TextAlign.center : TextAlign.start,
    );
  }
}

class HeroCtaButton extends StatelessWidget {
  const HeroCtaButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: 'Create Free Card',
      onPressed: () => context.go('/builder'),
      icon: Icons.arrow_forward_rounded,
      width: 230,
      height: 52,
    );
  }
}
