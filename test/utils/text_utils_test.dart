import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';

void main() {
  group('TextUtils', () {
    test('hasCodeBlock detects code blocks', () {
      expect(TextUtils.hasCodeBlock('```python\nprint("hello")\n```'), isTrue);
      expect(TextUtils.hasCodeBlock('regular text'), isFalse);
      expect(TextUtils.hasCodeBlock('inline `code`'), isTrue);
    });

    test('extractCodeBlocks extracts code blocks correctly', () {
      const String text = '''
Some text
```python
print("hello")
```
More text
```javascript
console.log("world");
```
      ''';

      final List<Map<String, String>> blocks =
          TextUtils.extractCodeBlocks(text);

      expect(blocks.length, equals(2));
      expect(blocks[0]['language'], equals('python'));
      expect(blocks[0]['code'], contains('print("hello")'));
      expect(blocks[1]['language'], equals('javascript'));
      expect(blocks[1]['code'], contains('console.log("world")'));
    });

    test('hasUrl detects URLs', () {
      expect(TextUtils.hasUrl('Check out https://example.com'), isTrue);
      expect(TextUtils.hasUrl('No URL here'), isFalse);
      expect(
        TextUtils.hasUrl('Multiple http://a.com and https://b.com'),
        isTrue,
      );
    });

    test('extractUrls extracts all URLs', () {
      const String text = 'Visit https://example.com and http://test.org';
      final List<String> urls = TextUtils.extractUrls(text);

      expect(urls.length, equals(2));
      expect(urls[0], equals('https://example.com'));
      expect(urls[1], equals('http://test.org'));
    });

    test('makeBold wraps text in bold syntax', () {
      expect(TextUtils.makeBold('text'), equals('**text**'));
    });

    test('makeItalic wraps text in italic syntax', () {
      expect(TextUtils.makeItalic('text'), equals('*text*'));
    });

    test('makeInlineCode wraps text in code syntax', () {
      expect(TextUtils.makeInlineCode('code'), equals('`code`'));
    });

    test('makeCodeBlock wraps text in code block syntax', () {
      expect(
        TextUtils.makeCodeBlock('code', language: 'python'),
        equals('```python\ncode\n```'),
      );
    });

    test('hasMention detects @mentions', () {
      expect(TextUtils.hasMention('Hello @john'), isTrue);
      expect(TextUtils.hasMention('No mention here'), isFalse);
    });

    test('extractMentions extracts all mentions', () {
      const String text = 'Hey @john and @jane, check this out!';
      final List<String> mentions = TextUtils.extractMentions(text);

      expect(mentions.length, equals(2));
      expect(mentions[0], equals('john'));
      expect(mentions[1], equals('jane'));
    });

    test('truncate shortens long text', () {
      const String longText = 'This is a very long text that needs truncating';
      final String truncated = TextUtils.truncate(longText, 20);

      expect(truncated.length, lessThanOrEqualTo(20));
      expect(truncated.endsWith('...'), isTrue);
    });

    test('truncate returns original text if shorter than max', () {
      const String shortText = 'Short text';
      final String result = TextUtils.truncate(shortText, 20);

      expect(result, equals(shortText));
    });

    test('stripMarkdown removes markdown formatting', () {
      const String markdown = '**bold** *italic* `code` [link](url)';
      final String stripped = TextUtils.stripMarkdown(markdown);

      expect(stripped, equals('bold italic code link'));
    });

    test('wordCount counts words correctly', () {
      expect(TextUtils.wordCount('Hello world'), equals(2));
      expect(TextUtils.wordCount('  Multiple   spaces  '), equals(2));
      expect(TextUtils.wordCount(''), equals(0));
    });

    test('estimateReadingTime calculates reading time', () {
      final String text = List<String>.generate(300, (int i) => 'word').join(' ');
      final int minutes = TextUtils.estimateReadingTime(text);

      expect(minutes, greaterThanOrEqualTo(1));
    });
  });
}
