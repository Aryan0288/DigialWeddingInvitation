import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/routes/routes.dart';
import 'data/repositories/invitation_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive storage boxes for dual persistence pipeline
  await Hive.initFlutter();
  final draftsBox = await Hive.openBox('drafts');
  final mockPublishedBox = await Hive.openBox('mock_published');
  final mockRsvpsBox = await Hive.openBox('mock_rsvps');

  // Asynchronously initialize storage before launching UI
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        draftsBoxProvider.overrideWithValue(draftsBox),
        mockPublishedBoxProvider.overrideWithValue(mockPublishedBox),
        mockRsvpsBoxProvider.overrideWithValue(mockRsvpsBox),
      ],
      child: const WeddingInvitationApp(),
    ),
  );
}

class WeddingInvitationApp extends ConsumerWidget {
  const WeddingInvitationApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Digital Wedding Invitation Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37), // Luxury Gold
          brightness: Brightness.dark,
          primary: const Color(0xFFD4AF37),
          surface: const Color(0xFF0F1626), // Royal Navy Black
          background: const Color(0xFF070B19), // Midnight Dark
        ),
        scaffoldBackgroundColor: const Color(0xFF070B19),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F1626),
          elevation: 0,
        ),
        // Premium default typography configuration
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Serif', fontSize: 32, fontWeight: FontWeight.w300, color: Colors.white),
          headlineMedium: TextStyle(fontFamily: 'Serif', fontSize: 24, fontWeight: FontWeight.normal, color: Color(0xFFD4AF37)),
          bodyLarge: TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
        ),
      ),
      routerConfig: router,
    );
  }
}
