import 'package:equatable/equatable.dart';
import 'message_sender.dart';
import 'message_status.dart';
import 'message_attachment.dart';
import 'chat_user.dart';

/// Represents a single message in the chat.
///
/// Messages can contain text, attachments, and metadata. They can be sent
/// by users, assistants, or the system.
///
/// Example:
/// ```dart
/// final message = ChatMessage(
///   id: 'msg_123',
///   content: 'Hello, how can I help you?',
///   sender: MessageSender.assistant,
///   user: assistantUser,
///   timestamp: DateTime.now(),
/// );
/// ```
class ChatMessage extends Equatable {
  /// Creates a chat message.
  const ChatMessage({
    required this.id,
    required this.content,
    required this.sender,
    required this.user,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.attachments = const <MessageAttachment>[],
    this.metadata,
    this.replyTo,
    this.reactions = const <String, List<String>>{},
    this.isEdited = false,
    this.isDeleted = false,
  });

  /// Unique identifier for the message
  final String id;

  /// Text content of the message
  final String content;

  /// The sender type (user, assistant, or system)
  final MessageSender sender;

  /// The user who sent this message
  final ChatUser user;

  /// When the message was sent
  final DateTime timestamp;

  /// Current delivery status of the message
  final MessageStatus status;

  /// List of attachments (images, files, audio)
  final List<MessageAttachment> attachments;

  /// Additional metadata for the message (optional)
  final Map<String, dynamic>? metadata;

  /// The message this is replying to (optional)
  final ChatMessage? replyTo;

  /// Map of emoji reactions to list of user IDs who reacted
  final Map<String, List<String>> reactions;

  /// Whether this message has been edited
  final bool isEdited;

  /// Whether this message has been deleted
  final bool isDeleted;

  /// Returns whether this message has any attachments.
  bool get hasAttachments => attachments.isNotEmpty;

  /// Returns whether this message is a reply to another message.
  bool get isReply => replyTo != null;

  /// Returns whether this message has any reactions.
  bool get hasReactions => reactions.isNotEmpty;

  /// Returns the total count of all reactions.
  int get reactionCount => reactions.values
      .fold<int>(0, (int sum, List<String> users) => sum + users.length);

  /// Creates a copy of this message with the given fields replaced.
  ChatMessage copyWith({
    String? id,
    String? content,
    MessageSender? sender,
    ChatUser? user,
    DateTime? timestamp,
    MessageStatus? status,
    List<MessageAttachment>? attachments,
    Map<String, dynamic>? metadata,
    ChatMessage? replyTo,
    Map<String, List<String>>? reactions,
    bool? isEdited,
    bool? isDeleted,
  }) =>
      ChatMessage(
        id: id ?? this.id,
        content: content ?? this.content,
        sender: sender ?? this.sender,
        user: user ?? this.user,
        timestamp: timestamp ?? this.timestamp,
        status: status ?? this.status,
        attachments: attachments ?? this.attachments,
        metadata: metadata ?? this.metadata,
        replyTo: replyTo ?? this.replyTo,
        reactions: reactions ?? this.reactions,
        isEdited: isEdited ?? this.isEdited,
        isDeleted: isDeleted ?? this.isDeleted,
      );

  /// Converts this message to a JSON map.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'content': content,
        'sender': sender.name,
        'user': user.toJson(),
        'timestamp': timestamp.toIso8601String(),
        'status': status.name,
        'attachments': attachments
            .map((MessageAttachment a) => a.toJson())
            .toList(),
        if (metadata != null) 'metadata': metadata,
        if (replyTo != null) 'replyTo': replyTo!.toJson(),
        'reactions': reactions,
        'isEdited': isEdited,
        'isDeleted': isDeleted,
      };

  /// Creates a message from a JSON map.
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        content: json['content'] as String,
        sender: MessageSender.values.firstWhere(
          (MessageSender e) => e.name == json['sender'],
        ),
        user: ChatUser.fromJson(json['user'] as Map<String, dynamic>),
        timestamp: DateTime.parse(json['timestamp'] as String),
        status: MessageStatus.values.firstWhere(
          (MessageStatus e) => e.name == json['status'],
          orElse: () => MessageStatus.sent,
        ),
        attachments: (json['attachments'] as List<dynamic>?)
                ?.map((dynamic e) =>
                    MessageAttachment.fromJson(e as Map<String, dynamic>))
                .toList() ??
            <MessageAttachment>[],
        metadata: json['metadata'] as Map<String, dynamic>?,
        replyTo: json['replyTo'] != null
            ? ChatMessage.fromJson(json['replyTo'] as Map<String, dynamic>)
            : null,
        reactions: (json['reactions'] as Map<String, dynamic>?)?.map(
              (String key, dynamic value) =>
                  MapEntry<String, List<String>>(
                key,
                (value as List<dynamic>).cast<String>(),
              ),
            ) ??
            <String, List<String>>{},
        isEdited: json['isEdited'] as bool? ?? false,
        isDeleted: json['isDeleted'] as bool? ?? false,
      );

  @override
  List<Object?> get props => <Object?>[
        id,
        content,
        sender,
        user,
        timestamp,
        status,
        attachments,
        metadata,
        replyTo,
        reactions,
        isEdited,
        isDeleted,
      ];
}
