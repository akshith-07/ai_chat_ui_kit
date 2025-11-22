import 'package:equatable/equatable.dart';
import 'attachment_type.dart';

/// Represents a file attachment in a chat message.
///
/// Attachments can be images, documents, audio files, or videos.
///
/// Example:
/// ```dart
/// final attachment = MessageAttachment(
///   type: AttachmentType.image,
///   url: 'https://example.com/image.png',
///   name: 'screenshot.png',
///   size: 1024000,
/// );
/// ```
class MessageAttachment extends Equatable {
  /// Creates a message attachment.
  const MessageAttachment({
    required this.type,
    required this.url,
    required this.name,
    this.size,
    this.thumbnailUrl,
    this.mimeType,
  });

  /// The type of attachment (image, file, audio, video)
  final AttachmentType type;

  /// The URL where the attachment can be accessed
  final String url;

  /// The display name of the attachment
  final String name;

  /// The size of the attachment in bytes (optional)
  final int? size;

  /// Optional thumbnail URL for preview (useful for videos and documents)
  final String? thumbnailUrl;

  /// The MIME type of the attachment (optional)
  final String? mimeType;

  /// Returns a human-readable file size string.
  ///
  /// Example: 1024 bytes -> "1.0 KB"
  String get formattedSize {
    if (size == null) return 'Unknown size';
    final double sizeInKb = size! / 1024;
    if (sizeInKb < 1024) {
      return '${sizeInKb.toStringAsFixed(1)} KB';
    }
    final double sizeInMb = sizeInKb / 1024;
    return '${sizeInMb.toStringAsFixed(1)} MB';
  }

  /// Creates a copy of this attachment with the given fields replaced.
  MessageAttachment copyWith({
    AttachmentType? type,
    String? url,
    String? name,
    int? size,
    String? thumbnailUrl,
    String? mimeType,
  }) =>
      MessageAttachment(
        type: type ?? this.type,
        url: url ?? this.url,
        name: name ?? this.name,
        size: size ?? this.size,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        mimeType: mimeType ?? this.mimeType,
      );

  /// Converts this attachment to a JSON map.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type.name,
        'url': url,
        'name': name,
        if (size != null) 'size': size,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        if (mimeType != null) 'mimeType': mimeType,
      };

  /// Creates an attachment from a JSON map.
  factory MessageAttachment.fromJson(Map<String, dynamic> json) =>
      MessageAttachment(
        type: AttachmentType.values.firstWhere(
          (AttachmentType e) => e.name == json['type'],
        ),
        url: json['url'] as String,
        name: json['name'] as String,
        size: json['size'] as int?,
        thumbnailUrl: json['thumbnailUrl'] as String?,
        mimeType: json['mimeType'] as String?,
      );

  @override
  List<Object?> get props => <Object?>[
        type,
        url,
        name,
        size,
        thumbnailUrl,
        mimeType,
      ];
}
