import 'package:equatable/equatable.dart';

/// Represents a user in the chat system.
///
/// Can represent either the current user or the AI assistant.
///
/// Example:
/// ```dart
/// final user = ChatUser(
///   id: 'user_123',
///   name: 'John Doe',
///   avatar: 'https://example.com/avatar.jpg',
///   isOnline: true,
/// );
/// ```
class ChatUser extends Equatable {
  /// Creates a chat user.
  const ChatUser({
    required this.id,
    required this.name,
    this.avatar,
    this.isOnline = false,
    this.metadata,
  });

  /// Unique identifier for the user
  final String id;

  /// Display name of the user
  final String name;

  /// URL to the user's avatar image (optional)
  final String? avatar;

  /// Whether the user is currently online
  final bool isOnline;

  /// Additional metadata for the user (optional)
  final Map<String, dynamic>? metadata;

  /// Returns the user's initials for avatar fallback.
  ///
  /// Example: "John Doe" -> "JD"
  String get initials {
    final List<String> nameParts = name.trim().split(' ');
    if (nameParts.isEmpty) return '?';
    if (nameParts.length == 1) {
      return nameParts[0].substring(0, 1).toUpperCase();
    }
    return (nameParts[0].substring(0, 1) + nameParts[1].substring(0, 1))
        .toUpperCase();
  }

  /// Creates a copy of this user with the given fields replaced.
  ChatUser copyWith({
    String? id,
    String? name,
    String? avatar,
    bool? isOnline,
    Map<String, dynamic>? metadata,
  }) =>
      ChatUser(
        id: id ?? this.id,
        name: name ?? this.name,
        avatar: avatar ?? this.avatar,
        isOnline: isOnline ?? this.isOnline,
        metadata: metadata ?? this.metadata,
      );

  /// Converts this user to a JSON map.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        if (avatar != null) 'avatar': avatar,
        'isOnline': isOnline,
        if (metadata != null) 'metadata': metadata,
      };

  /// Creates a user from a JSON map.
  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
        id: json['id'] as String,
        name: json['name'] as String,
        avatar: json['avatar'] as String?,
        isOnline: json['isOnline'] as bool? ?? false,
        metadata: json['metadata'] as Map<String, dynamic>?,
      );

  @override
  List<Object?> get props => <Object?>[
        id,
        name,
        avatar,
        isOnline,
        metadata,
      ];
}
