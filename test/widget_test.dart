// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:digital_wedding_invitation/main.dart';

void main() {
  testWidgets('Wedding invitation displays names and RSVP button', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DigitalWeddingInvitationApp());

    // Verify that the couple names are displayed.
    expect(find.text('Aryan & Priya'), findsOneWidget);

    // Verify that the RSVP button is displayed.
    expect(find.text('RSVP Now'), findsOneWidget);
  });
}
