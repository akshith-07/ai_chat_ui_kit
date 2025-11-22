import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';

void main() {
  group('ChatMessage', () {
    late ChatUser testUser;
    late ChatMessage testMessage;

    setUp(() {
      testUser = const ChatUser(
        id: 'user_1',
        name: 'Test User',
      );

      testMessage = ChatMessage(
        id: 'msg_1',
        content: 'Hello, world!',
        sender: MessageSender.user,
        user: testUser,
        timestamp: DateTime(2025, 1, 1, 12, 0),
      );
    });

    test('creates a message with required fields', () {
      expect(testMessage.id, equals('msg_1'));
      expect(testMessage.content, equals('Hello, world!'));
      expect(testMessage.sender, equals(MessageSender.user));
      expect(testMessage.user, equals(testUser));
    });

    test('has default values for optional fields', () {
      expect(testMessage.status, equals(MessageStatus.sent));
      expect(testMessage.attachments, isEmpty);
      expect(testMessage.metadata, isNull);
      expect(testMessage.replyTo, isNull);
      expect(testMessage.reactions, isEmpty);
      expect(testMessage.isEdited, isFalse);
      expect(testMessage.isDeleted, isFalse);
    });

    test('hasAttachments returns true when attachments exist', () {
      final ChatMessage messageWithAttachment = testMessage.copyWith(
        attachments: <MessageAttachment>[
          const MessageAttachment(
            type: AttachmentType.image,
            url: 'https://example.com/image.png',
            name: 'image.png',
          ),
        ],
      );

      expect(messageWithAttachment.hasAttachments, isTrue);
      expect(testMessage.hasAttachments, isFalse);
    });

    test('hasReactions returns true when reactions exist', () {
      final ChatMessage messageWithReactions = testMessage.copyWith(
        reactions: <String, List<String>>{
          '👍': <String>['user_2', 'user_3'],
        },
      );

      expect(messageWithReactions.hasReactions, isTrue);
      expect(messageWithReactions.reactionCount, equals(2));
      expect(testMessage.hasReactions, isFalse);
    });

    test('isReply returns true when replyTo is set', () {
      final ChatMessage replyMessage = testMessage.copyWith(
        replyTo: testMessage,
      );

      expect(replyMessage.isReply, isTrue);
      expect(testMessage.isReply, isFalse);
    });

    test('copyWith creates a new instance with updated fields', () {
      final ChatMessage updatedMessage = testMessage.copyWith(
        content: 'Updated content',
        isEdited: true,
      );

      expect(updatedMessage.content, equals('Updated content'));
      expect(updatedMessage.isEdited, isTrue);
      expect(updatedMessage.id, equals(testMessage.id));
      expect(updatedMessage.sender, equals(testMessage.sender));
    });

    test('toJson converts message to JSON', () {
      final Map<String, dynamic> json = testMessage.toJson();

      expect(json['id'], equals('msg_1'));
      expect(json['content'], equals('Hello, world!'));
      expect(json['sender'], equals('user'));
      expect(json['status'], equals('sent'));
    });

    test('fromJson creates message from JSON', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 'msg_2',
        'content': 'Test message',
        'sender': 'assistant',
        'user': <String, dynamic>{
          'id': 'user_2',
          'name': 'Assistant',
          'isOnline': false,
        },
        'timestamp': '2025-01-01T12:00:00.000',
        'status': 'sent',
        'attachments': <dynamic>[],
        'reactions': <String, dynamic>{},
        'isEdited': false,
        'isDeleted': false,
      };

      final ChatMessage message = ChatMessage.fromJson(json);

      expect(message.id, equals('msg_2'));
      expect(message.content, equals('Test message'));
      expect(message.sender, equals(MessageSender.assistant));
    });
  });
}
