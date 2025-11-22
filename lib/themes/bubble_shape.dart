/// Defines the shape style for message bubbles.
///
/// Used to customize the appearance of chat message bubbles.
enum BubbleShape {
  /// Rounded corners on all sides
  rounded,

  /// Sharp corners (no rounding)
  square,

  /// Rounded with a tail pointing left (for received messages)
  tailLeft,

  /// Rounded with a tail pointing right (for sent messages)
  tailRight,
}
