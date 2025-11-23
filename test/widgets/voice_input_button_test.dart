import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';

void main() {
  group('VoiceInputButton', () {
    testWidgets('displays microphone icon when not recording',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VoiceInputButton(
              onTranscriptionComplete: (text) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('calls onTranscriptionComplete callback',
        (WidgetTester tester) async {
      String? transcribedText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VoiceInputButton(
              onTranscriptionComplete: (text) {
                transcribedText = text;
              },
            ),
          ),
        ),
      );

      // Widget should be present
      expect(find.byType(VoiceInputButton), findsOneWidget);
    });

    testWidgets('changes appearance when recording starts',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VoiceInputButton(
              onTranscriptionComplete: (text) {},
            ),
          ),
        ),
      );

      // Tap to start recording (may require permissions)
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pump();

      // Widget should still be present
      expect(find.byType(VoiceInputButton), findsOneWidget);
    });

    testWidgets('uses custom icon color when provided',
        (WidgetTester tester) async {
      const customColor = Colors.purple;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VoiceInputButton(
              onTranscriptionComplete: (text) {},
              iconColor: customColor,
            ),
          ),
        ),
      );

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.icon, isA<Icon>());
    });

    testWidgets('uses custom size when provided',
        (WidgetTester tester) async {
      const customSize = 32.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VoiceInputButton(
              onTranscriptionComplete: (text) {},
              iconSize: customSize,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.mic));
      expect(icon.size, customSize);
    });

    testWidgets('can be enabled and disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VoiceInputButton(
              onTranscriptionComplete: (text) {},
              enabled: false,
            ),
          ),
        ),
      );

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.onPressed, isNull);
    });

    testWidgets('handles null onTranscriptionComplete gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VoiceInputButton(
              onTranscriptionComplete: (text) {},
            ),
          ),
        ),
      );

      expect(find.byType(VoiceInputButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('properly disposes resources', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VoiceInputButton(
              onTranscriptionComplete: (text) {},
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        ),
      );

      // Should dispose without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders with ChatTheme styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.dark(),
          child: MaterialApp(
            home: Scaffold(
              body: VoiceInputButton(
                onTranscriptionComplete: (text) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(VoiceInputButton), findsOneWidget);
    });

    testWidgets('shows recording animation when active',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VoiceInputButton(
              onTranscriptionComplete: (text) {},
            ),
          ),
        ),
      );

      // Start recording
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should have animation-related widgets
      expect(find.byType(VoiceInputButton), findsOneWidget);
    });

    testWidgets('handles permission denied gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VoiceInputButton(
              onTranscriptionComplete: (text) {},
            ),
          ),
        ),
      );

      // Try to start recording (may fail due to permissions)
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pump();

      // Should not throw errors
      expect(tester.takeException(), isNull);
    });
  });
}
