import 'package:flutter/material.dart';
import 'chat_theme.dart';

/// Provides the chat theme to descendant widgets.
///
/// Place this widget at the root of your chat interface to provide
/// theme data to all child widgets.
///
/// Example:
/// ```dart
/// ChatThemeProvider(
///   theme: ChatTheme.light(),
///   child: ChatScreen(...),
/// )
/// ```
class ChatThemeProvider extends InheritedWidget {
  /// Creates a chat theme provider.
  const ChatThemeProvider({
    required this.theme,
    required super.child,
    super.key,
  });

  /// The theme to provide to descendants
  final ChatTheme theme;

  /// Retrieves the nearest [ChatTheme] from the widget tree.
  ///
  /// Throws an error if no [ChatThemeProvider] is found in the tree.
  static ChatTheme of(BuildContext context) {
    final ChatThemeProvider? provider =
        context.dependOnInheritedWidgetOfExactType<ChatThemeProvider>();
    assert(
      provider != null,
      'ChatThemeProvider not found in widget tree. '
      'Wrap your widget with ChatThemeProvider.',
    );
    return provider!.theme;
  }

  /// Retrieves the nearest [ChatTheme] from the widget tree, or null if not found.
  static ChatTheme? maybeOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<ChatThemeProvider>()
          ?.theme;

  @override
  bool updateShouldNotify(ChatThemeProvider oldWidget) =>
      theme != oldWidget.theme;
}
