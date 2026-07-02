import 'package:flutter_agentic/flutter_agentic.dart';
import 'package:flutter_agentic_ui/flutter_agentic_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  test('send adds a user message and a completed agent reply', () async {
    final controller = AgenticChatController(
        agent: GenesisAgent(provider: FakeProvider(reply: 'Hi there')));

    await controller.send('Hello');

    expect(controller.messages.length, 2);
    expect(controller.messages[0].isUser, isTrue);
    expect(controller.messages[0].text, 'Hello');
    expect(controller.messages[1].isUser, isFalse);
    expect(controller.messages[1].text, 'Hi there');
    expect(controller.messages[1].status, ChatMessageStatus.complete);
    expect(controller.isBusy, isFalse);
  });

  test('empty or whitespace input is ignored', () async {
    final controller =
        AgenticChatController(agent: GenesisAgent(provider: FakeProvider()));
    await controller.send('   ');
    expect(controller.messages, isEmpty);
  });

  test('isBusy is true while the agent works and blocks concurrent sends',
      () async {
    final controller = AgenticChatController(
        agent: GenesisAgent(
            provider: FakeProvider(delay: const Duration(milliseconds: 50))));

    final first = controller.send('one');
    expect(controller.isBusy, isTrue);
    await controller.send('two'); // ignored while busy
    await first;

    expect(controller.messages.length, 2);
    expect(controller.messages[0].text, 'one');
  });

  test('streaming send grows the reply text token by token', () async {
    final controller = AgenticChatController(
        agent: GenesisAgent(
            provider: FakeProvider(
                streamTokens: ['A', 'B', 'C'],
                delay: const Duration(milliseconds: 5))));

    final snapshots = <String>[];
    controller.addListener(() {
      if (controller.messages.length == 2) {
        snapshots.add(controller.messages[1].text);
      }
    });

    await controller.send('go', stream: true);

    expect(controller.messages[1].text, 'ABC');
    expect(controller.messages[1].status, ChatMessageStatus.complete);
    expect(snapshots, containsAllInOrder(['A', 'AB', 'ABC']));
  });

  test('tool-calling turn records steps on the reply message', () async {
    final tool = GenesisTool.define(
      name: 'get_time',
      description: 'Returns the time',
      params: {},
      execute: (args) async => {'time': '12:00'},
    );
    final provider = FakeProvider(
      reply: 'It is noon.',
      toolCall: const ToolCall(toolName: 'get_time', arguments: {}),
    );
    final controller = AgenticChatController(
        agent: GenesisAgent(provider: provider, tools: [tool]));

    await controller.send('what time is it?');

    final reply = controller.messages[1];
    expect(reply.text, 'It is noon.');
    expect(reply.steps.whereType<ToolCallStep>().length, 1);
    expect(reply.steps.whereType<ToolResultStep>().length, 1);
  });

  test('provider failure marks the reply as error, controller stays usable',
      () async {
    final controller = AgenticChatController(
        agent: GenesisAgent(provider: BrokenProvider()));

    await controller.send('hello');

    expect(controller.messages[1].status, ChatMessageStatus.error);
    expect(controller.isBusy, isFalse);
  });

  test('clear empties messages and agent history', () async {
    final agent = GenesisAgent(provider: FakeProvider());
    final controller = AgenticChatController(agent: agent);
    await controller.send('hello');
    await controller.clear();
    expect(controller.messages, isEmpty);
    expect(await agent.getHistory(), isEmpty);
  });

  test('loadHistory restores persisted user/assistant turns', () async {
    final memory = InMemoryStore();
    final agent =
        GenesisAgent(provider: FakeProvider(reply: 'pong'), memory: memory);
    await agent.chat('ping');

    final controller = AgenticChatController(agent: agent);
    await controller.loadHistory();

    expect(controller.messages.length, 2);
    expect(controller.messages[0].text, 'ping');
    expect(controller.messages[1].text, 'pong');
  });
}
