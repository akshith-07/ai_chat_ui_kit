/// Represents the delivery status of a chat message.
///
/// Used to track the lifecycle of a message from sending to being read.
enum MessageStatus {
  /// Message is being sent
  sending,

  /// Message has been sent successfully
  sent,

  /// Message has been delivered to the recipient
  delivered,

  /// Message has been read by the recipient
  read,

  /// Message failed to send
  failed,
}
