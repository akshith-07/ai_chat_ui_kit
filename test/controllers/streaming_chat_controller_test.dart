import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';

void main() {
  group('StreamingChatController', () {
    late StreamingChatController controller;

    setUp(() {
      controller = StreamingChatController(
        bufferDelay: const Duration(milliseconds: 10),
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial state is streaming', () {
      expect(controller.state, equals(StreamingState.streaming));
      expect(controller.isStreaming, isTrue);
      expect(controller.streamedText, isEmpty);
      expect(controller.tokenCount, equals(0));
    });

    test('addText updates streamed text', () async {
      controller.addText('Hello');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(controller.streamedText, equals('Hello'));
      expect(controller.tokenCount, equals(1));
    });

    test('addTextImmediate updates text without buffering', () {
      controller.addTextImmediate('Hello');

      expect(controller.streamedText, equals('Hello'));
      expect(controller.tokenCount, equals(1));
    });

    test('complete marks streaming as complete', () {
      controller.addTextImmediate('Test');
      controller.complete();

      expect(controller.state, equals(StreamingState.completed));
      expect(controller.isComplete, isTrue);
      expect(controller.isStreaming, isFalse);
    });

    test('cancel marks streaming as cancelled', () {
      controller.addTextImmediate('Test');
      controller.cancel();

      expect(controller.state, equals(StreamingState.cancelled));
      expect(controller.isCancelled, isTrue);
      expect(controller.isStreaming, isFalse);
    });

    test('error marks streaming as error', () {
      controller.error('Test error');

      expect(controller.state, equals(StreamingState.error));
      expect(controller.hasError, isTrue);
      expect(controller.isStreaming, isFalse);
    });

    test('reset clears state', () {
      controller.addTextImmediate('Hello');
      controller.complete();
      controller.reset();

      expect(controller.state, equals(StreamingState.streaming));
      expect(controller.streamedText, isEmpty);
      expect(controller.tokenCount, equals(0));
    });

    test('callbacks are triggered', () async {
      String? updatedText;
      bool? completed;

      final StreamingChatController callbackController =
          StreamingChatController(
        bufferDelay: const Duration(milliseconds: 10),
        onUpdate: (String text) => updatedText = text,
        onComplete: () => completed = true,
      );

      callbackController.addText('Test');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(updatedText, equals('Test'));

      callbackController.complete();
      expect(completed, isTrue);

      callbackController.dispose();
    });

    test('tokensPerSecond calculates correctly', () async {
      for (int i = 0; i < 10; i++) {
        controller.addTextImmediate('token ');
      }

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(controller.tokensPerSecond, greaterThan(0));
    });
  });
}
