import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/chat_message.dart';
import '../themes/chat_theme.dart';
import '../themes/chat_theme_provider.dart';

/// A context menu for message actions.
///
/// Provides common actions like:
/// - Copy message content
/// - Reply to message
/// - Edit message (for user messages)
/// - Delete message
/// - Forward message
/// - React to message
/// - Select message
///
/// Example:
/// ```dart
/// MessageContextMenu.show(
///   context: context,
///   message: message,
///   position: tapPosition,
///   onCopy: (msg) => copyToClipboard(msg.content),
///   onReply: (msg) => startReply(msg),
///   onDelete: (msg) => deleteMessage(msg),
/// );
/// ```
class MessageContextMenu {
  /// Shows a context menu for the given message.
  static Future<void> show({
    required BuildContext context,
    required ChatMessage message,
    required Offset position,
    void Function(ChatMessage)? onCopy,
    void Function(ChatMessage)? onReply,
    void Function(ChatMessage)? onEdit,
    void Function(ChatMessage)? onDelete,
    void Function(ChatMessage)? onForward,
    void Function(ChatMessage, String)? onReact,
    void Function(ChatMessage)? onSelect,
    List<MessageContextMenuItem>? customActions,
  }) async {
    final theme = ChatThemeProvider.of(context);

    final items = <MessageContextMenuItem>[
      if (onCopy != null)
        MessageContextMenuItem(
          icon: Icons.copy,
          label: 'Copy',
          onTap: () {
            Navigator.of(context).pop();
            _copyToClipboard(message.content);
            onCopy(message);
          },
        ),
      if (onReply != null)
        MessageContextMenuItem(
          icon: Icons.reply,
          label: 'Reply',
          onTap: () {
            Navigator.of(context).pop();
            onReply(message);
          },
        ),
      if (onEdit != null && message.isUser && !message.isDeleted)
        MessageContextMenuItem(
          icon: Icons.edit,
          label: 'Edit',
          onTap: () {
            Navigator.of(context).pop();
            onEdit(message);
          },
        ),
      if (onReact != null)
        MessageContextMenuItem(
          icon: Icons.emoji_emotions,
          label: 'React',
          onTap: () {
            Navigator.of(context).pop();
            _showReactionPicker(context, message, onReact);
          },
        ),
      if (onForward != null)
        MessageContextMenuItem(
          icon: Icons.forward,
          label: 'Forward',
          onTap: () {
            Navigator.of(context).pop();
            onForward(message);
          },
        ),
      if (onSelect != null)
        MessageContextMenuItem(
          icon: Icons.check_circle_outline,
          label: 'Select',
          onTap: () {
            Navigator.of(context).pop();
            onSelect(message);
          },
        ),
      if (customActions != null) ...customActions,
      if (onDelete != null && !message.isDeleted)
        MessageContextMenuItem(
          icon: Icons.delete,
          label: 'Delete',
          destructive: true,
          onTap: () {
            Navigator.of(context).pop();
            _showDeleteConfirmation(context, message, onDelete);
          },
        ),
    ];

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: items.map((item) => _buildMenuItem(item, theme)).toList(),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  static PopupMenuItem _buildMenuItem(
    MessageContextMenuItem item,
    ChatTheme theme,
  ) {
    return PopupMenuItem(
      onTap: item.onTap,
      child: Row(
        children: [
          Icon(
            item.icon,
            size: 20,
            color: item.destructive ? Colors.red : theme.iconColor,
          ),
          const SizedBox(width: 12),
          Text(
            item.label,
            style: TextStyle(
              color: item.destructive ? Colors.red : theme.primaryTextColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  static void _showReactionPicker(
    BuildContext context,
    ChatMessage message,
    void Function(ChatMessage, String) onReact,
  ) {
    final commonEmojis = ['👍', '❤️', '😂', '😮', '😢', '🙏', '🎉', '🔥'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('React to message'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: commonEmojis.map((emoji) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                onReact(message, emoji);
              },
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  static void _showDeleteConfirmation(
    BuildContext context,
    ChatMessage message,
    void Function(ChatMessage) onDelete,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete message?'),
        content: const Text(
          'This message will be deleted. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete(message);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Represents a menu item in the message context menu.
class MessageContextMenuItem {
  /// Creates a context menu item.
  const MessageContextMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  /// Icon for the menu item
  final IconData icon;

  /// Label text
  final String label;

  /// Callback when item is tapped
  final VoidCallback onTap;

  /// Whether this is a destructive action (shown in red)
  final bool destructive;
}

/// A widget that wraps a message bubble with long-press context menu.
///
/// Example:
/// ```dart
/// MessageWithContextMenu(
///   message: message,
///   child: MessageBubble(message: message),
///   onCopy: (msg) => copyMessage(msg),
///   onReply: (msg) => replyToMessage(msg),
/// )
/// ```
class MessageWithContextMenu extends StatelessWidget {
  /// Creates a message with context menu wrapper.
  const MessageWithContextMenu({
    required this.message,
    required this.child,
    this.onCopy,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.onForward,
    this.onReact,
    this.onSelect,
    this.customActions,
    super.key,
  });

  /// The message to show context menu for
  final ChatMessage message;

  /// The child widget (usually MessageBubble)
  final Widget child;

  /// Callback when copy is selected
  final void Function(ChatMessage)? onCopy;

  /// Callback when reply is selected
  final void Function(ChatMessage)? onReply;

  /// Callback when edit is selected
  final void Function(ChatMessage)? onEdit;

  /// Callback when delete is selected
  final void Function(ChatMessage)? onDelete;

  /// Callback when forward is selected
  final void Function(ChatMessage)? onForward;

  /// Callback when react is selected
  final void Function(ChatMessage, String)? onReact;

  /// Callback when select is selected
  final void Function(ChatMessage)? onSelect;

  /// Custom actions to add to the menu
  final List<MessageContextMenuItem>? customActions;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        MessageContextMenu.show(
          context: context,
          message: message,
          position: details.globalPosition,
          onCopy: onCopy,
          onReply: onReply,
          onEdit: onEdit,
          onDelete: onDelete,
          onForward: onForward,
          onReact: onReact,
          onSelect: onSelect,
          customActions: customActions,
        );
      },
      child: child,
    );
  }
}
