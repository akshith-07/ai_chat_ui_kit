/// Represents the type of message attachment.
///
/// Used to distinguish between different types of files attached to messages.
enum AttachmentType {
  /// Image file (PNG, JPG, GIF, etc.)
  image,

  /// Document file (PDF, DOC, TXT, etc.)
  file,

  /// Audio file (MP3, WAV, etc.)
  audio,

  /// Video file (MP4, AVI, etc.)
  video,
}
