import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test/main.dart';
import 'package:video_player/video_player.dart'; // main.dart import

void main() {
  testWidgets('VideoApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget( MyApp());

    // Verify that the video player exists in the widget tree.
    expect(find.byType(VideoPlayer), findsOneWidget);
  });
}
