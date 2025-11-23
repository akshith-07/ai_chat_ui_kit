import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';

void main() {
  group('AvatarWidget', () {
    testWidgets('displays initials when no avatar URL provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AvatarWidget(
              user: ChatUser(
                id: '1',
                name: 'John Doe',
              ),
            ),
          ),
        ),
      );

      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('displays online indicator when user is online',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AvatarWidget(
              user: ChatUser(
                id: '1',
                name: 'John Doe',
                isOnline: true,
              ),
              showOnlineIndicator: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find Container with green decoration for online indicator
      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasGreenIndicator = containers.any((container) {
        final decoration = container.decoration as BoxDecoration?;
        return decoration?.color == Colors.green;
      });

      expect(hasGreenIndicator, isTrue);
    });

    testWidgets('does not display online indicator when user is offline',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AvatarWidget(
              user: ChatUser(
                id: '1',
                name: 'John Doe',
                isOnline: false,
              ),
              showOnlineIndicator: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not find green online indicator
      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasGreenIndicator = containers.any((container) {
        final decoration = container.decoration as BoxDecoration?;
        return decoration?.color == Colors.green;
      });

      expect(hasGreenIndicator, isFalse);
    });

    testWidgets('uses custom size when provided',
        (WidgetTester tester) async {
      const customSize = 60.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AvatarWidget(
              user: ChatUser(
                id: '1',
                name: 'John Doe',
              ),
              size: customSize,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );

      expect(container.constraints?.maxWidth, customSize);
      expect(container.constraints?.maxHeight, customSize);
    });

    testWidgets('uses custom background color when provided',
        (WidgetTester tester) async {
      const customColor = Colors.purple;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AvatarWidget(
              user: ChatUser(
                id: '1',
                name: 'John Doe',
              ),
              backgroundColor: customColor,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasPurpleBackground = containers.any((container) {
        final decoration = container.decoration as BoxDecoration?;
        return decoration?.color == customColor;
      });

      expect(hasPurpleBackground, isTrue);
    });

    testWidgets('displays CachedNetworkImage when avatar URL provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AvatarWidget(
              user: ChatUser(
                id: '1',
                name: 'John Doe',
                avatar: 'https://example.com/avatar.jpg',
              ),
            ),
          ),
        ),
      );

      // Should find ClipRRect (used for network image)
      expect(find.byType(ClipRRect), findsWidgets);
    });

    testWidgets('generates correct initials for single name',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AvatarWidget(
              user: ChatUser(
                id: '1',
                name: 'Madonna',
              ),
            ),
          ),
        ),
      );

      expect(find.text('M'), findsOneWidget);
    });

    testWidgets('generates correct initials for multi-word name',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AvatarWidget(
              user: ChatUser(
                id: '1',
                name: 'John Paul Jones',
              ),
            ),
          ),
        ),
      );

      expect(find.text('JJ'), findsOneWidget);
    });

    testWidgets('uses custom text color when provided',
        (WidgetTester tester) async {
      const customTextColor = Colors.amber;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AvatarWidget(
              user: ChatUser(
                id: '1',
                name: 'John Doe',
              ),
              textColor: customTextColor,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('JD'));
      expect(textWidget.style?.color, customTextColor);
    });
  });
}
