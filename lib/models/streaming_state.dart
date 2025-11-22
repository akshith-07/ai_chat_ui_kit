/// Represents the state of a streaming message.
///
/// Used to track the progress of streaming AI responses.
enum StreamingState {
  /// Message is currently streaming
  streaming,

  /// Streaming has completed successfully
  completed,

  /// An error occurred during streaming
  error,

  /// Streaming was cancelled by the user
  cancelled,
}
