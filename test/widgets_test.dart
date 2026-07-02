import 'package:flutter/material.dart';
import 'package:flutter_agentic/flutter_agentic.dart';
import 'package:flutter_agentic_ui/flutter_agentic_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AgenticChatView', () {
    testWidgets('shows empty state, sends a message, renders both bubbles',
        (tester) async {
      final controller = AgenticChatController(
          agent: GenesisAgent(provider: FakeProvider(reply: 'Hi human')));
      await tester.pumpWidget(wrap(AgenticChatView(controller: controller)));

      expect(find.text('Send a message to start'), findsOneWidget);

      await tester.enterText(
          find.byKey(const Key('agentic_chat_input')), 'Hello agent');
      await tester.tap(find.byKey(const Key('agentic_chat_send')));
      await tester.pumpAndSettle();

      expect(find.text('Hello agent'), findsOneWidget);
      expect(find.text('Hi human'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('input clears after send and is disabled while busy',
        (tester) async {
      final controller = AgenticChatController(
          agent: GenesisAgent(
              provider:
                  FakeProvider(delay: const Duration(milliseconds: 300))));
      await tester.pumpWidget(wrap(AgenticChatView(controller: controller)));

      await tester.enterText(
          find.byKey(const Key('agentic_chat_input')), 'slow question');
      await tester.tap(find.byKey(const Key('agentic_chat_send')));
      await tester.pump(const Duration(milliseconds: 50));

      final field = tester
          .widget<TextField>(find.byKey(const Key('agentic_chat_input')));
      expect(field.enabled, isFalse);
      expect(field.controller!.text, isEmpty);
      // Typing indicator visible while waiting.
      expect(find.byType(TypingIndicator), findsOneWidget);

      await tester.pumpAndSettle();
      final after = tester
          .widget<TextField>(find.byKey(const Key('agentic_chat_input')));
      expect(after.enabled, isTrue);
      controller.dispose();
    });

    testWidgets('streaming mode shows growing text', (tester) async {
      final controller = AgenticChatController(
          agent: GenesisAgent(
              provider: FakeProvider(
                  streamTokens: ['Once', ' upon', ' a time'],
                  delay: const Duration(milliseconds: 20))));
      await tester.pumpWidget(wrap(
          AgenticChatView(controller: controller, streamResponses: true)));

      await tester.enterText(
          find.byKey(const Key('agentic_chat_input')), 'story');
      await tester.tap(find.byKey(const Key('agentic_chat_send')));
      await tester.pump(const Duration(milliseconds: 30));

      expect(find.textContaining('Once'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.textContaining('Once upon a time'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('submitting via keyboard action also sends', (tester) async {
      final controller = AgenticChatController(
          agent: GenesisAgent(provider: FakeProvider(reply: 'ok')));
      await tester.pumpWidget(wrap(AgenticChatView(controller: controller)));

      await tester.enterText(
          find.byKey(const Key('agentic_chat_input')), 'enter key');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pumpAndSettle();

      expect(find.text('enter key'), findsOneWidget);
      controller.dispose();
    });
  });

  group('ChatBubble', () {
    testWidgets('error message uses error styling', (tester) async {
      await tester.pumpWidget(wrap(const ChatBubble(
        message: ChatMessage(
          id: 'x',
          isUser: false,
          text: 'Something broke',
          status: ChatMessageStatus.error,
        ),
      )));
      expect(find.text('Something broke'), findsOneWidget);
    });

    testWidgets('agent reply with tool steps shows the steps tile',
        (tester) async {
      await tester.pumpWidget(wrap(const ChatBubble(
        message: ChatMessage(
          id: 'x',
          isUser: false,
          text: 'It is noon.',
          steps: [
            ToolCallStep('get_time', {}),
            ToolResultStep('get_time', {'time': '12:00'}),
            FinalResponseStep('It is noon.'),
          ],
        ),
      )));
      expect(find.byKey(const Key('agentic_steps_tile')), findsOneWidget);
      expect(find.text('1 tool call'), findsOneWidget);

      await tester.tap(find.byKey(const Key('agentic_steps_tile')));
      await tester.pumpAndSettle();
      expect(find.textContaining('get_time'), findsWidgets);
    });
  });

  group('AgentStepsView', () {
    testWidgets('renders nothing when only a final response exists',
        (tester) async {
      await tester.pumpWidget(wrap(const AgentStepsView(
        steps: [FinalResponseStep('done')],
      )));
      expect(find.byKey(const Key('agentic_steps_tile')), findsNothing);
    });

    testWidgets('counts multiple tool calls', (tester) async {
      await tester.pumpWidget(wrap(const AgentStepsView(
        steps: [
          ToolCallStep('a', {}),
          ToolResultStep('a', {}),
          ToolCallStep('b', {}),
          ToolResultStep('b', {}),
        ],
      )));
      expect(find.text('2 tool calls'), findsOneWidget);
    });
  });

  group('TypingIndicator', () {
    testWidgets('animates without errors', (tester) async {
      await tester.pumpWidget(wrap(const TypingIndicator()));
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pump(const Duration(milliseconds: 450));
      expect(find.byType(TypingIndicator), findsOneWidget);
    });
  });
}
