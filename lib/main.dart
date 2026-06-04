import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
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
      theme: AppTheme.theme,
      routerConfig: router,
    );
  }
}
