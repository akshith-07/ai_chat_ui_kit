/// Represents the sender type of a chat message.
///
/// Used to distinguish between different message senders in the chat interface.
enum MessageSender {
  /// Message sent by the user
  user,

  /// Message sent by the AI assistant
  assistant,

  /// System message (e.g., notifications, status updates)
  system,
}
