/// Utility class for text manipulation in chat messages.
class TextUtils {
  /// Private constructor to prevent instantiation
  TextUtils._();

  /// Detects if a string contains code blocks (markdown).
  static bool hasCodeBlock(String text) =>
      text.contains('```') || text.contains('`');

  /// Extracts code blocks from markdown text.
  ///
  /// Returns a list of maps containing language and code.
  static List<Map<String, String>> extractCodeBlocks(String text) {
    final List<Map<String, String>> blocks = <Map<String, String>>[];
    final RegExp regex = RegExp(r'```(\w+)?\n([\s\S]*?)```');
    final Iterable<RegExpMatch> matches = regex.allMatches(text);

    for (final RegExpMatch match in matches) {
      blocks.add(<String, String>{
        'language': match.group(1) ?? 'text',
        'code': match.group(2) ?? '',
      });
    }

    return blocks;
  }

  /// Detects if a string contains URLs.
  static bool hasUrl(String text) {
    final RegExp urlRegex = RegExp(
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    );
    return urlRegex.hasMatch(text);
  }

  /// Extracts all URLs from a string.
  static List<String> extractUrls(String text) {
    final RegExp urlRegex = RegExp(
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    );
    return urlRegex
        .allMatches(text)
        .map((RegExpMatch match) => match.group(0)!)
        .toList();
  }

  /// Wraps text with markdown bold syntax.
  static String makeBold(String text) => '**$text**';

  /// Wraps text with markdown italic syntax.
  static String makeItalic(String text) => '*$text*';

  /// Wraps text with markdown inline code syntax.
  static String makeInlineCode(String text) => '`$text`';

  /// Wraps text with markdown code block syntax.
  static String makeCodeBlock(String text, {String language = ''}) =>
      '```$language\n$text\n```';

  /// Detects if text contains @mentions.
  static bool hasMention(String text) => text.contains('@');

  /// Extracts all @mentions from text.
  static List<String> extractMentions(String text) {
    final RegExp mentionRegex = RegExp(r'@(\w+)');
    return mentionRegex
        .allMatches(text)
        .map((RegExpMatch match) => match.group(1)!)
        .toList();
  }

  /// Truncates text to a maximum length with ellipsis.
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// Removes markdown formatting from text.
  static String stripMarkdown(String text) => text
      .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1') // bold
      .replaceAll(RegExp(r'\*(.*?)\*'), r'$1') // italic
      .replaceAll(RegExp(r'`(.*?)`'), r'$1') // inline code
      .replaceAll(RegExp(r'```.*?\n([\s\S]*?)```'), r'$1') // code blocks
      .replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1'); // links

  /// Counts the number of words in a string.
  static int wordCount(String text) =>
      text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;

  /// Estimates reading time in minutes.
  static int estimateReadingTime(String text, {int wordsPerMinute = 200}) {
    final int words = wordCount(text);
    final int minutes = (words / wordsPerMinute).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  /// Highlights search terms in text with markers.
  static String highlightSearchTerms(String text, String searchTerm) {
    if (searchTerm.isEmpty) return text;
    final RegExp regex = RegExp(searchTerm, caseSensitive: false);
    return text.replaceAllMapped(
      regex,
      (Match match) => '===${match.group(0)}===',
    );
  }
}
