import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../data/models/invitation_model.dart';
import '../../../data/repositories/invitation_repository.dart';
import '../../widgets/templates_widgets.dart';

class LandingView extends ConsumerStatefulWidget {
  const LandingView({super.key});

  @override
  ConsumerState<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends ConsumerState<LandingView> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    final draftsBox = ref.watch(draftsBoxProvider);
    final savedInvitations = draftsBox.values
        .map((data) => InvitationModel.fromJson(Map<String, dynamic>.from(data)))
        .toList();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F1626), // Deep Royal Navy
              Color(0xFF070B19), // Midnight Black
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Rotating Background Mandala (Top Right Decor)
              Positioned(
                top: -100,
                right: -100,
                child: RotationTransition(
                  turns: _rotationController,
                  child: SizedBox(
                    width: 350,
                    height: 350,
                    child: CustomPaint(
                      painter: MandalaPainter(color: const Color(0xFFD4AF37).withOpacity(0.04)),
                    ),
                  ),
                ),
              ),

              // Bottom Left Decor
              Positioned(
                bottom: -150,
                left: -150,
                child: RotationTransition(
                  turns: _rotationController,
                  child: SizedBox(
                    width: 450,
                    height: 450,
                    child: CustomPaint(
                      painter: MandalaPainter(color: const Color(0xFFD4AF37).withOpacity(0.03)),
                    ),
                  ),
                ),
              ),

              // Main Content Panel
              Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Decorative Header Icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: Color(0xFFD4AF37),
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Subtitle
                        Text(
                          'ELEGANT & SELF-SERVICE',
                          style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 4.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFD4AF37).withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          'Digital Wedding Invitation\nWorkspace',
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: isMobile ? 32 : 54,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            height: 1.2,
                            letterSpacing: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),

                        // Supporting Description
                        Container(
                          constraints: const BoxConstraints(maxWidth: 550),
                          child: Text(
                            'Design modern, beautiful, and interactive Indian-themed wedding invitations in minutes. Select a preset template, fill in your details, and instantly generate shareable links or download print-ready images.',
                            style: TextStyle(
                              fontSize: isMobile ? 13 : 15,
                              color: Colors.white60,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Main Call-To-Action Button
                        SizedBox(
                          height: 56,
                          width: 250,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 10,
                              shadowColor: const Color(0xFFD4AF37).withOpacity(0.4),
                            ),
                            onPressed: () {
                              context.go('/builder');
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Create Invitation',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Saved drafts/invitations list
                        if (savedInvitations.isNotEmpty) ...[
                          Container(
                            constraints: const BoxConstraints(maxWidth: 700),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(color: Colors.white10),
                                const SizedBox(height: 24),
                                const Row(
                                  children: [
                                    Icon(Icons.bookmark_outline, color: Color(0xFFD4AF37), size: 20),
                                    SizedBox(width: 10),
                                    Text(
                                      'YOUR ACTIVE INVITATIONS',
                                      style: TextStyle(
                                        color: Color(0xFFD4AF37),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: savedInvitations.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final inv = savedInvitations[index];
                                    final names = inv.brideName.isEmpty && inv.groomName.isEmpty
                                        ? "Draft (Untitled)"
                                        : "${inv.brideName} & ${inv.groomName}";
                                    final dateStr = DateFormat('MMMM d, y').format(inv.weddingDate);

                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F1626).withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.white.withOpacity(0.04), width: 1),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  names,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Wedding Date: $dateStr',
                                                  style: const TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Action 1: Track RSVPs
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFD4AF37).withOpacity(0.1),
                                              foregroundColor: const Color(0xFFD4AF37),
                                              side: const BorderSide(color: Color(0xFFD4AF37), width: 0.5),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                            ),
                                            onPressed: () {
                                              context.go('/builder?id=${inv.id}&step=4');
                                            },
                                            icon: const Icon(Icons.analytics_outlined, size: 16),
                                            label: const Text(
                                              'Track RSVPs',
                                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Action 2: Edit Details
                                          OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              side: BorderSide(color: Colors.white.withOpacity(0.15)),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                            ),
                                            onPressed: () {
                                              context.go('/builder?id=${inv.id}');
                                            },
                                            icon: const Icon(Icons.edit_outlined, size: 16),
                                            label: const Text(
                                              'Edit Card',
                                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ],

                        // Features List Cards
                        Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildFeatureCard(
                              icon: Icons.palette_outlined,
                              title: 'Cultural Themes',
                              desc: 'Indian-centric gold, red, peacock, and floral designs.',
                            ),
                            _buildFeatureCard(
                              icon: Icons.flash_on_outlined,
                              title: 'Live Previews',
                              desc: 'Watch details update in real-time as you type them.',
                            ),
                            _buildFeatureCard(
                              icon: Icons.qr_code_scanner_outlined,
                              title: 'High-Res Downloads',
                              desc: 'Instant 1080x1920 PNG export for easy sharing.',
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1626).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white54,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
