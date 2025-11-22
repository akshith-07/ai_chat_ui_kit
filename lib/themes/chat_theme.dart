import 'package:flutter/material.dart';
import 'bubble_shape.dart';

/// Defines the visual theme for the chat interface.
///
/// Includes colors, typography, spacing, and bubble styling for both
/// light and dark modes.
///
/// Example:
/// ```dart
/// final theme = ChatTheme(
///   primaryColor: Colors.blue,
///   userBubbleColor: Colors.blue,
///   assistantBubbleColor: Colors.grey[300]!,
/// );
/// ```
class ChatTheme {
  /// Creates a chat theme with the specified styling.
  const ChatTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.userBubbleColor,
    required this.assistantBubbleColor,
    required this.systemBubbleColor,
    required this.userTextColor,
    required this.assistantTextColor,
    required this.systemTextColor,
    required this.timestampColor,
    required this.dividerColor,
    required this.inputBackgroundColor,
    required this.inputTextColor,
    required this.inputBorderColor,
    required this.sendButtonColor,
    required this.sendButtonDisabledColor,
    required this.iconColor,
    required this.errorColor,
    required this.linkColor,
    required this.codeBackgroundColor,
    required this.codeTextColor,
    this.bubbleShape = BubbleShape.rounded,
    this.borderRadius = 16.0,
    this.bubblePadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 10.0,
    ),
    this.messageSpacing = 8.0,
    this.avatarSize = 32.0,
    this.typingIndicatorDotSize = 8.0,
    this.textFontFamily,
    this.textFontSize = 15.0,
    this.textFontWeight = FontWeight.normal,
    this.timestampFontSize = 12.0,
    this.timestampFontWeight = FontWeight.w400,
    this.inputFontSize = 16.0,
    this.inputMaxLines = 5,
    this.showAvatars = true,
    this.showTimestamps = true,
    this.showUserNames = false,
    this.elevateUserBubbles = false,
    this.elevateAssistantBubbles = false,
  });

  // Colors
  /// Primary theme color (used for accents and highlights)
  final Color primaryColor;

  /// Secondary theme color
  final Color secondaryColor;

  /// Background color of the chat screen
  final Color backgroundColor;

  /// Background color for user message bubbles
  final Color userBubbleColor;

  /// Background color for assistant message bubbles
  final Color assistantBubbleColor;

  /// Background color for system message bubbles
  final Color systemBubbleColor;

  /// Text color in user message bubbles
  final Color userTextColor;

  /// Text color in assistant message bubbles
  final Color assistantTextColor;

  /// Text color in system message bubbles
  final Color systemTextColor;

  /// Color for timestamps
  final Color timestampColor;

  /// Color for dividers and separators
  final Color dividerColor;

  /// Background color for input field
  final Color inputBackgroundColor;

  /// Text color in input field
  final Color inputTextColor;

  /// Border color for input field
  final Color inputBorderColor;

  /// Color for send button when enabled
  final Color sendButtonColor;

  /// Color for send button when disabled
  final Color sendButtonDisabledColor;

  /// Color for icons
  final Color iconColor;

  /// Color for error states
  final Color errorColor;

  /// Color for links
  final Color linkColor;

  /// Background color for code blocks
  final Color codeBackgroundColor;

  /// Text color for code blocks
  final Color codeTextColor;

  // Shape and Spacing
  /// Shape style for message bubbles
  final BubbleShape bubbleShape;

  /// Border radius for bubbles and input fields
  final double borderRadius;

  /// Padding inside message bubbles
  final EdgeInsets bubblePadding;

  /// Vertical spacing between messages
  final double messageSpacing;

  /// Size of user avatars
  final double avatarSize;

  /// Size of typing indicator dots
  final double typingIndicatorDotSize;

  // Typography
  /// Font family for message text
  final String? textFontFamily;

  /// Font size for message text
  final double textFontSize;

  /// Font weight for message text
  final FontWeight textFontWeight;

  /// Font size for timestamps
  final double timestampFontSize;

  /// Font weight for timestamps
  final FontWeight timestampFontWeight;

  /// Font size for input field
  final double inputFontSize;

  /// Maximum lines for input field
  final int inputMaxLines;

  // Display Options
  /// Whether to show user avatars
  final bool showAvatars;

  /// Whether to show message timestamps
  final bool showTimestamps;

  /// Whether to show user names above bubbles
  final bool showUserNames;

  /// Whether to add elevation to user bubbles
  final bool elevateUserBubbles;

  /// Whether to add elevation to assistant bubbles
  final bool elevateAssistantBubbles;

  /// Creates a light theme with default values.
  factory ChatTheme.light({
    Color? primaryColor,
    Color? userBubbleColor,
    Color? assistantBubbleColor,
  }) =>
      ChatTheme(
        primaryColor: primaryColor ?? const Color(0xFF2196F3),
        secondaryColor: const Color(0xFF03A9F4),
        backgroundColor: const Color(0xFFF5F5F5),
        userBubbleColor: userBubbleColor ?? const Color(0xFF2196F3),
        assistantBubbleColor: assistantBubbleColor ?? const Color(0xFFE0E0E0),
        systemBubbleColor: const Color(0xFFFFF9C4),
        userTextColor: Colors.white,
        assistantTextColor: Colors.black87,
        systemTextColor: Colors.black87,
        timestampColor: Colors.black54,
        dividerColor: Colors.black12,
        inputBackgroundColor: Colors.white,
        inputTextColor: Colors.black87,
        inputBorderColor: const Color(0xFFE0E0E0),
        sendButtonColor: const Color(0xFF2196F3),
        sendButtonDisabledColor: Colors.grey,
        iconColor: Colors.black54,
        errorColor: const Color(0xFFD32F2F),
        linkColor: const Color(0xFF1976D2),
        codeBackgroundColor: const Color(0xFFF5F5F5),
        codeTextColor: const Color(0xFF212121),
      );

  /// Creates a dark theme with default values.
  factory ChatTheme.dark({
    Color? primaryColor,
    Color? userBubbleColor,
    Color? assistantBubbleColor,
  }) =>
      ChatTheme(
        primaryColor: primaryColor ?? const Color(0xFF90CAF9),
        secondaryColor: const Color(0xFF64B5F6),
        backgroundColor: const Color(0xFF121212),
        userBubbleColor: userBubbleColor ?? const Color(0xFF1976D2),
        assistantBubbleColor: assistantBubbleColor ?? const Color(0xFF2C2C2C),
        systemBubbleColor: const Color(0xFF424242),
        userTextColor: Colors.white,
        assistantTextColor: Colors.white,
        systemTextColor: Colors.white70,
        timestampColor: Colors.white60,
        dividerColor: Colors.white12,
        inputBackgroundColor: const Color(0xFF1E1E1E),
        inputTextColor: Colors.white,
        inputBorderColor: const Color(0xFF424242),
        sendButtonColor: const Color(0xFF90CAF9),
        sendButtonDisabledColor: Colors.grey,
        iconColor: Colors.white60,
        errorColor: const Color(0xFFEF5350),
        linkColor: const Color(0xFF64B5F6),
        codeBackgroundColor: const Color(0xFF2C2C2C),
        codeTextColor: const Color(0xFFE0E0E0),
      );

  /// Creates a copy of this theme with the specified fields replaced.
  ChatTheme copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? userBubbleColor,
    Color? assistantBubbleColor,
    Color? systemBubbleColor,
    Color? userTextColor,
    Color? assistantTextColor,
    Color? systemTextColor,
    Color? timestampColor,
    Color? dividerColor,
    Color? inputBackgroundColor,
    Color? inputTextColor,
    Color? inputBorderColor,
    Color? sendButtonColor,
    Color? sendButtonDisabledColor,
    Color? iconColor,
    Color? errorColor,
    Color? linkColor,
    Color? codeBackgroundColor,
    Color? codeTextColor,
    BubbleShape? bubbleShape,
    double? borderRadius,
    EdgeInsets? bubblePadding,
    double? messageSpacing,
    double? avatarSize,
    double? typingIndicatorDotSize,
    String? textFontFamily,
    double? textFontSize,
    FontWeight? textFontWeight,
    double? timestampFontSize,
    FontWeight? timestampFontWeight,
    double? inputFontSize,
    int? inputMaxLines,
    bool? showAvatars,
    bool? showTimestamps,
    bool? showUserNames,
    bool? elevateUserBubbles,
    bool? elevateAssistantBubbles,
  }) =>
      ChatTheme(
        primaryColor: primaryColor ?? this.primaryColor,
        secondaryColor: secondaryColor ?? this.secondaryColor,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        userBubbleColor: userBubbleColor ?? this.userBubbleColor,
        assistantBubbleColor: assistantBubbleColor ?? this.assistantBubbleColor,
        systemBubbleColor: systemBubbleColor ?? this.systemBubbleColor,
        userTextColor: userTextColor ?? this.userTextColor,
        assistantTextColor: assistantTextColor ?? this.assistantTextColor,
        systemTextColor: systemTextColor ?? this.systemTextColor,
        timestampColor: timestampColor ?? this.timestampColor,
        dividerColor: dividerColor ?? this.dividerColor,
        inputBackgroundColor: inputBackgroundColor ?? this.inputBackgroundColor,
        inputTextColor: inputTextColor ?? this.inputTextColor,
        inputBorderColor: inputBorderColor ?? this.inputBorderColor,
        sendButtonColor: sendButtonColor ?? this.sendButtonColor,
        sendButtonDisabledColor:
            sendButtonDisabledColor ?? this.sendButtonDisabledColor,
        iconColor: iconColor ?? this.iconColor,
        errorColor: errorColor ?? this.errorColor,
        linkColor: linkColor ?? this.linkColor,
        codeBackgroundColor: codeBackgroundColor ?? this.codeBackgroundColor,
        codeTextColor: codeTextColor ?? this.codeTextColor,
        bubbleShape: bubbleShape ?? this.bubbleShape,
        borderRadius: borderRadius ?? this.borderRadius,
        bubblePadding: bubblePadding ?? this.bubblePadding,
        messageSpacing: messageSpacing ?? this.messageSpacing,
        avatarSize: avatarSize ?? this.avatarSize,
        typingIndicatorDotSize:
            typingIndicatorDotSize ?? this.typingIndicatorDotSize,
        textFontFamily: textFontFamily ?? this.textFontFamily,
        textFontSize: textFontSize ?? this.textFontSize,
        textFontWeight: textFontWeight ?? this.textFontWeight,
        timestampFontSize: timestampFontSize ?? this.timestampFontSize,
        timestampFontWeight: timestampFontWeight ?? this.timestampFontWeight,
        inputFontSize: inputFontSize ?? this.inputFontSize,
        inputMaxLines: inputMaxLines ?? this.inputMaxLines,
        showAvatars: showAvatars ?? this.showAvatars,
        showTimestamps: showTimestamps ?? this.showTimestamps,
        showUserNames: showUserNames ?? this.showUserNames,
        elevateUserBubbles: elevateUserBubbles ?? this.elevateUserBubbles,
        elevateAssistantBubbles:
            elevateAssistantBubbles ?? this.elevateAssistantBubbles,
      );
}
