import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:digital_wedding_invitation/main.dart';
import 'package:digital_wedding_invitation/data/repositories/invitation_repository.dart';

// Lightweight FakeBox to mock Hive storage box in tests
class FakeBox extends Fake implements Box {
  final Map<dynamic, dynamic> _data = {};

  @override
  Iterable get values => _data.values;

  @override
  Iterable get keys => _data.keys;

  @override
  bool containsKey(key) => _data.containsKey(key);

  @override
  dynamic get(key, {defaultValue}) => _data[key] ?? defaultValue;

  @override
  Future<void> put(key, value) async {
    _data[key] = value;
  }
  
  @override
  Future<void> close() async {}

  @override
  Stream<BoxEvent> watch({key}) => const Stream.empty();
}

void main() {
  testWidgets('Landing page hero text and CTA button renders', (WidgetTester tester) async {
    // Seed mock initial values for testing SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    
    final draftsBox = FakeBox();
    final mockPubBox = FakeBox();
    final mockRsvpsBox = FakeBox();

    // Pump app inside ProviderScope
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          draftsBoxProvider.overrideWithValue(draftsBox),
          mockPublishedBoxProvider.overrideWithValue(mockPubBox),
          mockRsvpsBoxProvider.overrideWithValue(mockRsvpsBox),
        ],
        child: const WeddingInvitationApp(),
      ),
    );

    // Initial render of SplashView
    await tester.pump();

    // Advance clock by 2.6s to trigger redirect from SplashView to LandingView
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pump();

    // Verify that the Landing Page title elements are displayed.
    expect(
      find.byWidgetPredicate((widget) =>
          widget is RichText &&
          widget.text.toPlainText().contains('Craft Elegant') &&
          widget.text.toPlainText().contains('Wedding Cards')),
      findsOneWidget,
    );

    // Verify that the CTA button is displayed.
    expect(find.text('Create Free Card'), findsOneWidget);
  });
}
