import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../themes/chat_theme.dart';
import '../themes/chat_theme_provider.dart';
import '../utils/text_utils.dart';
import 'message_bubble.dart';

/// A widget for searching through chat messages with highlighted results.
///
/// Features:
/// - Real-time search with highlighting
/// - Navigate through search results
/// - Filter by sender (user/assistant)
/// - Show result count
///
/// Example:
/// ```dart
/// SearchMessagesWidget(
///   messages: allMessages,
///   onMessageSelected: (message) {
///     scrollToMessage(message);
///   },
/// )
/// ```
class SearchMessagesWidget extends StatefulWidget {
  /// Creates a search messages widget.
  const SearchMessagesWidget({
    required this.messages,
    this.onMessageSelected,
    this.onClose,
    super.key,
  });

  /// All messages to search through
  final List<ChatMessage> messages;

  /// Callback when a search result is selected
  final void Function(ChatMessage message)? onMessageSelected;

  /// Callback when search is closed
  final VoidCallback? onClose;

  @override
  State<SearchMessagesWidget> createState() => _SearchMessagesWidgetState();
}

class _SearchMessagesWidgetState extends State<SearchMessagesWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<ChatMessage> _searchResults = [];
  int _currentResultIndex = 0;
  bool _caseSensitive = false;
  String? _filterSender;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _currentResultIndex = 0;
      });
      return;
    }

    final results = widget.messages.where((message) {
      // Filter by sender if set
      if (_filterSender != null && message.sender.name != _filterSender) {
        return false;
      }

      // Search in content
      final content = _caseSensitive ? message.content : message.content.toLowerCase();
      final searchQuery = _caseSensitive ? query : query.toLowerCase();

      return content.contains(searchQuery);
    }).toList();

    setState(() {
      _searchResults = results;
      _currentResultIndex = results.isEmpty ? 0 : 1;
    });
  }

  void _navigateToResult(int delta) {
    if (_searchResults.isEmpty) return;

    setState(() {
      _currentResultIndex = (_currentResultIndex + delta - 1) % _searchResults.length + 1;
    });

    final message = _searchResults[_currentResultIndex - 1];
    widget.onMessageSelected?.call(message);
  }

  void _toggleCaseSensitive() {
    setState(() {
      _caseSensitive = !_caseSensitive;
    });
    _performSearch();
  }

  void _setFilterSender(String? sender) {
    setState(() {
      _filterSender = sender;
    });
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ChatThemeProvider.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSearchHeader(theme),
          if (_searchResults.isNotEmpty) _buildSearchResults(theme),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(ChatTheme theme) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.inputBackgroundColor,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.search, color: theme.iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: TextStyle(color: theme.inputTextColor),
                  decoration: InputDecoration(
                    hintText: 'Search messages...',
                    hintStyle: TextStyle(color: theme.iconColor),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (_searchResults.isNotEmpty) ...[
                Text(
                  '$_currentResultIndex/${_searchResults.length}',
                  style: TextStyle(
                    color: theme.secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_up),
                  iconSize: 20,
                  onPressed: () => _navigateToResult(-1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down),
                  iconSize: 20,
                  onPressed: () => _navigateToResult(1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
              IconButton(
                icon: const Icon(Icons.close),
                iconSize: 20,
                onPressed: widget.onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildFilterChip(
                'Case sensitive',
                _caseSensitive,
                () => _toggleCaseSensitive(),
                theme,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'User',
                _filterSender == 'user',
                () => _setFilterSender(_filterSender == 'user' ? null : 'user'),
                theme,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Assistant',
                _filterSender == 'assistant',
                () => _setFilterSender(_filterSender == 'assistant' ? null : 'assistant'),
                theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap, ChatTheme theme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? theme.primaryColor : theme.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? theme.primaryColor : theme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : theme.primaryTextColor,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(ChatTheme theme) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final message = _searchResults[index];
          final isCurrentResult = index == _currentResultIndex - 1;

          return Container(
            color: isCurrentResult
                ? theme.primaryColor.withOpacity(0.1)
                : Colors.transparent,
            child: ListTile(
              dense: true,
              leading: Icon(
                message.isUser ? Icons.person : Icons.smart_toy,
                color: theme.iconColor,
                size: 20,
              ),
              title: Text(
                _highlightSearchTerm(message.content, _searchController.text),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.primaryTextColor,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                _formatTimestamp(message.timestamp),
                style: TextStyle(
                  color: theme.secondaryTextColor,
                  fontSize: 12,
                ),
              ),
              onTap: () {
                setState(() {
                  _currentResultIndex = index + 1;
                });
                widget.onMessageSelected?.call(message);
              },
            ),
          );
        },
      ),
    );
  }

  String _highlightSearchTerm(String text, String searchTerm) {
    if (searchTerm.isEmpty) return text;

    final highlighted = TextUtils.highlightSearchTerms(text, [searchTerm]);
    return highlighted;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
