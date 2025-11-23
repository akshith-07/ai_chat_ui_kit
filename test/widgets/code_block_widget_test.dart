import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';

void main() {
  group('CodeBlockWidget', () {
    testWidgets('displays code content', (WidgetTester tester) async {
      const testCode = 'print("Hello, World!")';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CodeBlockWidget(
              code: testCode,
              language: 'python',
            ),
          ),
        ),
      );

      expect(find.textContaining('Hello, World'), findsOneWidget);
    });

    testWidgets('displays language label', (WidgetTester tester) async {
      const testCode = 'console.log("test");';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CodeBlockWidget(
              code: testCode,
              language: 'javascript',
            ),
          ),
        ),
      );

      expect(find.text('javascript'), findsOneWidget);
    });

    testWidgets('shows copy button', (WidgetTester tester) async {
      const testCode = 'test code';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CodeBlockWidget(
              code: testCode,
              language: 'dart',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('copies code to clipboard when copy button tapped',
        (WidgetTester tester) async {
      const testCode = 'test code to copy';

      // Mock clipboard
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'Clipboard.setData') {
            return null;
          }
          return null;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CodeBlockWidget(
              code: testCode,
              language: 'dart',
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();

      // Should not throw any errors
      expect(tester.takeException(), isNull);

      // Cleanup
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    testWidgets('shows "Copied!" feedback after copying',
        (WidgetTester tester) async {
      const testCode = 'test';

      // Mock clipboard
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'Clipboard.setData') {
            return null;
          }
          return null;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CodeBlockWidget(
              code: testCode,
              language: 'dart',
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Copied!'), findsOneWidget);

      // Cleanup
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    testWidgets('uses custom background color when provided',
        (WidgetTester tester) async {
      const testCode = 'test';
      const customColor = Colors.purple;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CodeBlockWidget(
              code: testCode,
              language: 'dart',
              backgroundColor: customColor,
            ),
          ),
        ),
      );

      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasCustomBackground = containers.any((container) {
        final decoration = container.decoration as BoxDecoration?;
        return decoration?.color == customColor;
      });

      expect(hasCustomBackground, isTrue);
    });

    testWidgets('handles empty code gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CodeBlockWidget(
              code: '',
              language: 'dart',
            ),
          ),
        ),
      );

      expect(find.byType(CodeBlockWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles long code with scrolling',
        (WidgetTester tester) async {
      final longCode = List.generate(50, (i) => 'line $i').join('\n');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CodeBlockWidget(
              code: longCode,
              language: 'dart',
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('supports multiple programming languages',
        (WidgetTester tester) async {
      final languages = ['python', 'javascript', 'java', 'dart', 'cpp', 'sql'];

      for (final lang in languages) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CodeBlockWidget(
                code: 'test code',
                language: lang,
              ),
            ),
          ),
        );

        expect(find.text(lang), findsOneWidget);
      }
    });

    testWidgets('renders with ChatTheme styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.dark(),
          child: const MaterialApp(
            home: Scaffold(
              body: CodeBlockWidget(
                code: 'test',
                language: 'dart',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CodeBlockWidget), findsOneWidget);
    });
  });
}
