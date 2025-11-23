import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';

/// Service for exporting chat history to various formats.
///
/// Supported formats:
/// - JSON: Structured data with all message properties
/// - Plain text: Human-readable conversation format
/// - Markdown: Formatted text with markdown syntax
/// - CSV: Spreadsheet-compatible format
///
/// Example:
/// ```dart
/// final exporter = ExportService();
/// final jsonData = await exporter.exportToJson(messages);
/// final textData = await exporter.exportToText(messages);
/// ```
class ExportService {
  /// Creates an export service.
  const ExportService();

  /// Exports messages to JSON format.
  ///
  /// Returns a JSON string containing all message data including
  /// metadata, attachments, reactions, and timestamps.
  String exportToJson(List<ChatMessage> messages) {
    final data = messages.map((message) => message.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Exports messages to plain text format.
  ///
  /// Format:
  /// ```
  /// [Timestamp] Sender Name:
  /// Message content
  ///
  /// [Timestamp] Sender Name:
  /// Message content
  /// ```
  String exportToText(List<ChatMessage> messages, {
    bool includeTimestamps = true,
    bool includeMetadata = false,
  }) {
    final buffer = StringBuffer();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    for (final message in messages) {
      if (message.isDeleted) {
        buffer.writeln('[Deleted message]');
        buffer.writeln();
        continue;
      }

      // Header
      if (includeTimestamps) {
        buffer.write('[${dateFormat.format(message.timestamp)}] ');
      }

      buffer.write('${message.user.name}:');

      if (message.isEdited) {
        buffer.write(' (edited)');
      }

      buffer.writeln();

      // Content
      buffer.writeln(message.content);

      // Metadata
      if (includeMetadata) {
        if (message.attachments.isNotEmpty) {
          buffer.writeln('Attachments: ${message.attachments.length}');
        }

        if (message.reactions.isNotEmpty) {
          final totalReactions = message.reactions.values
              .fold<int>(0, (sum, list) => sum + list.length);
          buffer.writeln('Reactions: $totalReactions');
        }

        if (message.replyTo != null) {
          buffer.writeln('Replying to: "${message.replyTo!.content}"');
        }
      }

      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Exports messages to Markdown format.
  ///
  /// Format:
  /// ```markdown
  /// ## Sender Name
  /// *Timestamp*
  ///
  /// Message content (with markdown preserved)
  ///
  /// ---
  /// ```
  String exportToMarkdown(List<ChatMessage> messages) {
    final buffer = StringBuffer();
    final dateFormat = DateFormat('MMMM d, yyyy \'at\' h:mm a');

    buffer.writeln('# Chat Export');
    buffer.writeln();
    buffer.writeln('Exported on ${dateFormat.format(DateTime.now())}');
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln();

    for (final message in messages) {
      if (message.isDeleted) {
        buffer.writeln('*[Message deleted]*');
        buffer.writeln();
        buffer.writeln('---');
        buffer.writeln();
        continue;
      }

      // Header
      buffer.writeln('## ${message.user.name}');
      buffer.writeln('*${dateFormat.format(message.timestamp)}*');

      if (message.isEdited) {
        buffer.writeln('*(edited)*');
      }

      buffer.writeln();

      // Reply context
      if (message.replyTo != null) {
        buffer.writeln('> Replying to:');
        buffer.writeln('> ${message.replyTo!.content}');
        buffer.writeln();
      }

      // Content
      buffer.writeln(message.content);
      buffer.writeln();

      // Attachments
      if (message.attachments.isNotEmpty) {
        buffer.writeln('**Attachments:**');
        for (final attachment in message.attachments) {
          buffer.writeln('- ${attachment.name} (${attachment.formattedSize})');
        }
        buffer.writeln();
      }

      // Reactions
      if (message.reactions.isNotEmpty) {
        buffer.write('**Reactions:** ');
        final reactionStrings = message.reactions.entries.map(
          (entry) => '${entry.key} ${entry.value.length}',
        );
        buffer.writeln(reactionStrings.join(', '));
        buffer.writeln();
      }

      buffer.writeln('---');
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Exports messages to CSV format.
  ///
  /// Columns: ID, Timestamp, Sender, Content, Status, Edited, Deleted, Attachments, Reactions
  String exportToCsv(List<ChatMessage> messages) {
    final buffer = StringBuffer();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    // Header
    buffer.writeln(
      'ID,Timestamp,Sender,Sender Name,Content,Status,Edited,Deleted,Reply To,Attachments,Reactions',
    );

    // Rows
    for (final message in messages) {
      final fields = [
        message.id,
        dateFormat.format(message.timestamp),
        message.sender.name,
        _escapeCsv(message.user.name),
        _escapeCsv(message.content),
        message.status.name,
        message.isEdited.toString(),
        message.isDeleted.toString(),
        message.replyTo?.id ?? '',
        message.attachments.length.toString(),
        message.reactions.length.toString(),
      ];

      buffer.writeln(fields.join(','));
    }

    return buffer.toString();
  }

  /// Exports chat statistics and analytics.
  ///
  /// Returns a JSON object with various statistics about the chat.
  Map<String, dynamic> exportStatistics(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      return {
        'total_messages': 0,
        'period': null,
        'participants': [],
      };
    }

    final userMessages = messages.where((m) => m.isUser).length;
    final assistantMessages = messages.where((m) => m.isAssistant).length;
    final editedMessages = messages.where((m) => m.isEdited).length;
    final deletedMessages = messages.where((m) => m.isDeleted).length;

    final totalWords = messages.fold<int>(
      0,
      (sum, m) => sum + m.content.split(' ').length,
    );

    final totalReactions = messages.fold<int>(
      0,
      (sum, m) => sum + m.reactions.values.fold<int>(
        0,
        (rSum, list) => rSum + list.length,
      ),
    );

    final participants = messages.map((m) => m.user.id).toSet().toList();

    final firstMessage = messages.first.timestamp;
    final lastMessage = messages.last.timestamp;
    final duration = lastMessage.difference(firstMessage);

    return {
      'total_messages': messages.length,
      'user_messages': userMessages,
      'assistant_messages': assistantMessages,
      'edited_messages': editedMessages,
      'deleted_messages': deletedMessages,
      'total_words': totalWords,
      'average_words_per_message': (totalWords / messages.length).round(),
      'total_reactions': totalReactions,
      'unique_participants': participants.length,
      'period': {
        'start': firstMessage.toIso8601String(),
        'end': lastMessage.toIso8601String(),
        'duration_hours': duration.inHours,
      },
      'attachments': {
        'total': messages.fold<int>(
          0,
          (sum, m) => sum + m.attachments.length,
        ),
      },
    };
  }

  /// Helper method to escape CSV special characters.
  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Exports messages filtered by date range.
  List<ChatMessage> filterByDateRange(
    List<ChatMessage> messages,
    DateTime startDate,
    DateTime endDate,
  ) {
    return messages.where((message) {
      return message.timestamp.isAfter(startDate) &&
          message.timestamp.isBefore(endDate);
    }).toList();
  }

  /// Exports messages filtered by sender.
  List<ChatMessage> filterBySender(
    List<ChatMessage> messages,
    String senderId,
  ) {
    return messages.where((message) => message.user.id == senderId).toList();
  }

  /// Gets a summary of the conversation.
  String generateSummary(List<ChatMessage> messages, {int maxMessages = 10}) {
    if (messages.isEmpty) return 'No messages to summarize.';

    final buffer = StringBuffer();
    final stats = exportStatistics(messages);

    buffer.writeln('Chat Summary');
    buffer.writeln('=============');
    buffer.writeln();
    buffer.writeln('Total messages: ${stats['total_messages']}');
    buffer.writeln('User messages: ${stats['user_messages']}');
    buffer.writeln('Assistant messages: ${stats['assistant_messages']}');
    buffer.writeln('Total words: ${stats['total_words']}');
    buffer.writeln();

    if (messages.length <= maxMessages) {
      buffer.writeln('All messages:');
    } else {
      buffer.writeln('Last $maxMessages messages:');
    }

    buffer.writeln();

    final displayMessages = messages.length <= maxMessages
        ? messages
        : messages.sublist(messages.length - maxMessages);

    for (final message in displayMessages) {
      buffer.writeln('${message.user.name}: ${message.content}');
    }

    return buffer.toString();
  }
}
