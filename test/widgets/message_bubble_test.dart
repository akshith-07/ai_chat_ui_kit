import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';

void main() {
  group('MessageBubble', () {
    final testUser = ChatUser(id: '1', name: 'Test User');
    final testAssistant = ChatUser(id: '2', name: 'AI Assistant');

    testWidgets('displays message content', (WidgetTester tester) async {
      final message = ChatMessage(
        id: '1',
        content: 'Hello, this is a test message',
        sender: MessageSender.user,
        user: testUser,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageBubble(message: message),
            ),
          ),
        ),
      );

      expect(find.textContaining('Hello, this is a test message'), findsOneWidget);
    });

    testWidgets('displays user avatar', (WidgetTester tester) async {
      final message = ChatMessage(
        id: '1',
        content: 'Test',
        sender: MessageSender.user,
        user: testUser,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageBubble(
                message: message,
                showAvatar: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AvatarWidget), findsOneWidget);
    });

    testWidgets('hides avatar when showAvatar is false',
        (WidgetTester tester) async {
      final message = ChatMessage(
        id: '1',
        content: 'Test',
        sender: MessageSender.user,
        user: testUser,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageBubble(
                message: message,
                showAvatar: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AvatarWidget), findsNothing);
    });

    testWidgets('displays timestamp when showTimestamp is true',
        (WidgetTester tester) async {
      final message = ChatMessage(
        id: '1',
        content: 'Test',
        sender: MessageSender.user,
        user: testUser,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageBubble(
                message: message,
                showTimestamp: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MessageTimestamp), findsOneWidget);
    });

    testWidgets('displays message status icon', (WidgetTester tester) async {
      final message = ChatMessage(
        id: '1',
        content: 'Test',
        sender: MessageSender.user,
        user: testUser,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageBubble(
                message: message,
                showStatus: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('calls onTap callback when message is tapped',
        (WidgetTester tester) async {
      bool tapped = false;
      final message = ChatMessage(
        id: '1',
        content: 'Test',
        sender: MessageSender.user,
        user: testUser,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageBubble(
                message: message,
                onTap: (msg) => tapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MessageBubble));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('calls onLongPress callback when message is long pressed',
        (WidgetTester tester) async {
      bool longPressed = false;
      final message = ChatMessage(
        id: '1',
        content: 'Test',
        sender: MessageSender.user,
        user: testUser,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageBubble(
                message: message,
                onLongPress: (msg) => longPressed = true,
              ),
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(MessageBubble));
      await tester.pump();

      expect(longPressed, isTrue);
    });

    testWidgets('displays edited indicator for edited messages',
        (WidgetTester tester) async {
      final message = ChatMessage(
        id: '1',
        content: 'Test',
        sender: MessageSender.user,
        user: testUser,
        timestamp: DateTime.now(),
        isEdited: true,
      );

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageBubble(message: message),
            ),
          ),
        ),
      );

      expect(find.text('(edited)'), findsOneWidget);
    });

    testWidgets('displays reactions when present', (WidgetTester tester) async {
      final message = ChatMessage(
        id: '1',
        content: 'Test',
        sender: MessageSender.user,
        user: testUser,
        timestamp: DateTime.now(),
        reactions: {'👍': ['user1', 'user2'], '❤️': ['user3']},
      );

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageBubble(message: message),
            ),
          ),
        ),
      );

      expect(find.text('👍'), findsOneWidget);
      expect(find.text('❤️'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('displays reply preview when message is a reply',
        (WidgetTester tester) async {
      final replyTo = ChatMessage(
        id: '0',
        content: 'Original message',
        sender: MessageSender.assistant,
        user: testAssistant,
        timestamp: DateTime.now(),
      );

      final message = ChatMessage(
        id: '1',
        content: 'Reply message',
        sender: MessageSender.user,
        user: testUser,
        timestamp: DateTime.now(),
        replyTo: replyTo,
      );

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageBubble(message: message),
            ),
          ),
        ),
      );

      expect(find.textContaining('Original message'), findsOneWidget);
    });

    testWidgets('aligns user messages to the right',
        (WidgetTester tester) async {
      final message = ChatMessage(
        id: '1',
        content: 'User message',
        sender: MessageSender.user,
        user: testUser,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageBubble(message: message),
            ),
          ),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row).first);
      expect(row.mainAxisAlignment, MainAxisAlignment.end);
    });

    testWidgets('aligns assistant messages to the left',
        (WidgetTester tester) async {
      final message = ChatMessage(
        id: '1',
        content: 'Assistant message',
        sender: MessageSender.assistant,
        user: testAssistant,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageBubble(message: message),
            ),
          ),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row).first);
      expect(row.mainAxisAlignment, MainAxisAlignment.start);
    });

    testWidgets('renders markdown content', (WidgetTester tester) async {
      final message = ChatMessage(
        id: '1',
        content: '**Bold text** and *italic text*',
        sender: MessageSender.assistant,
        user: testAssistant,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageBubble(message: message),
            ),
          ),
        ),
      );

      // Should find markdown content
      expect(find.textContaining('Bold text'), findsOneWidget);
    });

    testWidgets('handles deleted messages', (WidgetTester tester) async {
      final message = ChatMessage(
        id: '1',
        content: 'Original content',
        sender: MessageSender.user,
        user: testUser,
        timestamp: DateTime.now(),
        isDeleted: true,
      );

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageBubble(message: message),
            ),
          ),
        ),
      );

      expect(find.text('This message was deleted'), findsOneWidget);
    });
  });
}
