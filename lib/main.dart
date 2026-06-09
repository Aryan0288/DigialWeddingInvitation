import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/routes.dart';
import 'data/repositories/invitation_repository.dart';
import 'presentation/widgets/templates_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-load all Google Fonts used across the app so they're cached before first frame.
  // This prevents HTTP font fetches from blocking the UI thread during scroll.
  GoogleFonts.pendingFonts([
    GoogleFonts.outfit(),
    GoogleFonts.playfairDisplay(),
    GoogleFonts.poppins(),
    GoogleFonts.greatVibes(),
    GoogleFonts.cormorantGaramond(),
  ]);
  
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

class PrecacheAssetsWrapper extends StatefulWidget {
  final Widget child;
  const PrecacheAssetsWrapper({super.key, required this.child});

  @override
  State<PrecacheAssetsWrapper> createState() => _PrecacheAssetsWrapperState();
}

class _PrecacheAssetsWrapperState extends State<PrecacheAssetsWrapper> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // Pre-cache all design PNG and JPG assets during app initialization
      for (final assetImage in AppAssetImages.cachedImages.values) {
        precacheImage(assetImage, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class WeddingInvitationApp extends ConsumerWidget {
  const WeddingInvitationApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return PrecacheAssetsWrapper(
      child: MaterialApp.router(
        title: 'Digital Wedding Invitation Builder',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        routerConfig: router,
      ),
    );
  }
}
