import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';

void main() {
  group('ChatUser', () {
    test('creates a user with required fields', () {
      const ChatUser user = ChatUser(
        id: 'user_1',
        name: 'John Doe',
      );

      expect(user.id, equals('user_1'));
      expect(user.name, equals('John Doe'));
      expect(user.isOnline, isFalse);
      expect(user.avatar, isNull);
    });

    test('initials returns correct value for single name', () {
      const ChatUser user = ChatUser(
        id: 'user_1',
        name: 'John',
      );

      expect(user.initials, equals('J'));
    });

    test('initials returns correct value for full name', () {
      const ChatUser user = ChatUser(
        id: 'user_1',
        name: 'John Doe',
      );

      expect(user.initials, equals('JD'));
    });

    test('initials returns correct value for name with spaces', () {
      const ChatUser user = ChatUser(
        id: 'user_1',
        name: '  John   Doe  ',
      );

      expect(user.initials, equals('JD'));
    });

    test('copyWith creates new instance with updated fields', () {
      const ChatUser user = ChatUser(
        id: 'user_1',
        name: 'John Doe',
        isOnline: false,
      );

      final ChatUser updatedUser = user.copyWith(isOnline: true);

      expect(updatedUser.isOnline, isTrue);
      expect(updatedUser.id, equals(user.id));
      expect(updatedUser.name, equals(user.name));
    });

    test('toJson converts user to JSON', () {
      const ChatUser user = ChatUser(
        id: 'user_1',
        name: 'John Doe',
        avatar: 'https://example.com/avatar.jpg',
        isOnline: true,
      );

      final Map<String, dynamic> json = user.toJson();

      expect(json['id'], equals('user_1'));
      expect(json['name'], equals('John Doe'));
      expect(json['avatar'], equals('https://example.com/avatar.jpg'));
      expect(json['isOnline'], isTrue);
    });

    test('fromJson creates user from JSON', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 'user_2',
        'name': 'Jane Smith',
        'avatar': 'https://example.com/avatar2.jpg',
        'isOnline': true,
      };

      final ChatUser user = ChatUser.fromJson(json);

      expect(user.id, equals('user_2'));
      expect(user.name, equals('Jane Smith'));
      expect(user.avatar, equals('https://example.com/avatar2.jpg'));
      expect(user.isOnline, isTrue);
    });
  });
}
