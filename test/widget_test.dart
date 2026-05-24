import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:digital_wedding_invitation/main.dart';
import 'package:digital_wedding_invitation/data/repositories/invitation_repository.dart';

void main() {
  testWidgets('Landing page hero text and CTA button renders', (WidgetTester tester) async {
    // Seed mock initial values for testing SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Pump app inside ProviderScope
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const WeddingInvitationApp(),
      ),
    );

    // Wait for the widgets to render
    await tester.pumpAndSettle();

    // Verify that the Landing Page title elements are displayed.
    expect(find.textContaining('Digital Wedding Invitation'), findsOneWidget);

    // Verify that the CTA button is displayed.
    expect(find.text('Create Invitation'), findsOneWidget);
  });
}
