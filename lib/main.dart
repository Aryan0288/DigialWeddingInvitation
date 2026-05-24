import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const DigitalWeddingInvitationApp());
}

class DigitalWeddingInvitationApp extends StatelessWidget {
  const DigitalWeddingInvitationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Wedding Invitation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37), // Luxury Gold
          brightness: Brightness.dark,
          primary: const Color(0xFFD4AF37),
          surface: const Color(0xFF0F1626), // Royal Navy Black
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Serif', fontSize: 36, fontWeight: FontWeight.w300, color: Color(0xFFF9F6F0)),
          headlineMedium: TextStyle(fontFamily: 'Serif', fontSize: 28, fontWeight: FontWeight.normal, color: Color(0xFFD4AF37)),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
        ),
      ),
      home: const InvitationHomeScreen(),
    );
  }
}

class InvitationHomeScreen extends StatefulWidget {
  const InvitationHomeScreen({super.key});

  @override
  State<InvitationHomeScreen> createState() => _InvitationHomeScreenState();
}

class _InvitationHomeScreenState extends State<InvitationHomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeInAnimation;
  late Timer _countdownTimer;
  Duration _timeLeft = const Duration();
  final DateTime _weddingDate = DateTime(2026, 10, 18, 18, 0, 0); // Wedding date: Oct 18, 2026 at 6:00 PM

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final difference = _weddingDate.difference(now);
    if (mounted) {
      setState(() {
        _timeLeft = difference.isNegative ? Duration.zero : difference;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _countdownTimer.cancel();
    super.dispose();
  }

  // Action: Launch RSVP Dialog
  void _showRSVPDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F1626),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return const RSVPBottomSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0B1021),
              Color(0xFF050714),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: FadeTransition(
              opacity: _fadeInAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    // Elegant Header Icon / Accent
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD4AF37), width: 1),
                        ),
                        child: const Icon(
                          Icons.favorite_border_rounded,
                          color: Color(0xFFD4AF37),
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Invitation Text
                    Text(
                      'THE WEDDING INVITATION',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFD4AF37),
                            letterSpacing: 4.0,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 24),
                    // Couple Names
                    const Text(
                      'Aryan & Priya',
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 42,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Together with their families, invite you to join them in celebrating their love.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white60,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // Countdown Section
                    _buildCountdownCard(),

                    const SizedBox(height: 32),

                    // Details Cards (Date & Time / Venue)
                    _buildDetailCard(
                      icon: Icons.calendar_today_outlined,
                      title: 'WHEN',
                      subtitle1: 'Sunday, October 18, 2026',
                      subtitle2: '6:00 PM onwards',
                    ),
                    const SizedBox(height: 16),
                    _buildDetailCard(
                      icon: Icons.location_on_outlined,
                      title: 'WHERE',
                      subtitle1: 'The Grand Palace Resort',
                      subtitle2: 'Grand Ballroom, Hall A, New Delhi',
                      trailing: TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Opening Location in Maps...'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.map, size: 16, color: Color(0xFFD4AF37)),
                        label: const Text(
                          'View Map',
                          style: TextStyle(color: Color(0xFFD4AF37), fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Call To Action: RSVP
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: const Color(0xFFD4AF37).withOpacity(0.3),
                        ),
                        onPressed: _showRSVPDialog,
                        child: const Text(
                          'RSVP Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Please respond by September 15, 2026',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownCard() {
    final days = _timeLeft.inDays;
    final hours = _timeLeft.inHours % 24;
    final minutes = _timeLeft.inMinutes % 60;
    final seconds = _timeLeft.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1626),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'COUNTDOWN TO THE BIG DAY',
            style: TextStyle(
              color: const Color(0xFFD4AF37).withOpacity(0.7),
              fontSize: 11,
              letterSpacing: 2.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeItem(days.toString().padLeft(2, '0'), 'DAYS'),
              _buildDivider(),
              _buildTimeItem(hours.toString().padLeft(2, '0'), 'HOURS'),
              _buildDivider(),
              _buildTimeItem(minutes.toString().padLeft(2, '0'), 'MINS'),
              _buildDivider(),
              _buildTimeItem(seconds.toString().padLeft(2, '0'), 'SECS'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.white38,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Text(
      ':',
      style: TextStyle(
        fontSize: 24,
        color: const Color(0xFFD4AF37).withOpacity(0.5),
        fontWeight: FontWeight.w300,
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String subtitle1,
    required String subtitle2,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1626).withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFFD4AF37).withOpacity(0.8),
                    fontSize: 11,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle2,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(height: 8),
                  trailing,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RSVPBottomSheet extends StatefulWidget {
  const RSVPBottomSheet({super.key});

  @override
  State<RSVPBottomSheet> createState() => _RSVPBottomSheetState();
}

class _RSVPBottomSheetState extends State<RSVPBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _guestCount = 1;
  String _mealPreference = 'Standard';
  bool _isAttending = true;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Standard keyboard offset adjustment for bottom sheet
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    if (_isSubmitted) {
      return Padding(
        padding: EdgeInsets.fromLTRB(24, 32, 24, 32 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1E3A2F),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Thank You!',
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isAttending
                  ? "We are delighted to know you are attending our big day. Your response has been recorded successfully!"
                  : "We are sorry you won't be able to make it, but thank you for letting us know!",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white60,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD4AF37)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Close',
                  style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'RSVP Response',
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
            const Divider(color: Colors.white10),
            const SizedBox(height: 16),
            
            // Name Field
            const Text(
              'YOUR NAME',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter your full name',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Colors.white.withOpacity(0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Attendance Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'WILL YOU BE ATTENDING?',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Yes'),
                      selected: _isAttending,
                      onSelected: (selected) {
                        setState(() {
                          _isAttending = true;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('No'),
                      selected: !_isAttending,
                      onSelected: (selected) {
                        setState(() {
                          _isAttending = false;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_isAttending) ...[
              // Guest Count Dropdown
              const Text(
                'NUMBER OF GUESTS',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _guestCount,
                    dropdownColor: const Color(0xFF0F1626),
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD4AF37)),
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    items: [1, 2, 3, 4, 5]
                        .map((val) => DropdownMenuItem<int>(
                              value: val,
                              child: Text('$val Guest${val > 1 ? "s" : ""}'),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _guestCount = val;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Meal Preference
              const Text(
                'MEAL PREFERENCE',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['Standard', 'Vegetarian', 'Vegan'].map((pref) {
                  final isSelected = _mealPreference == pref;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(pref),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _mealPreference = pref;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
            ],

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _submitForm,
                child: const Text(
                  'Submit Response',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
