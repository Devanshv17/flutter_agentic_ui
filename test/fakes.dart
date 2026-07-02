import 'dart:async';

import 'package:flutter_agentic/flutter_agentic.dart';

/// Provider that replies with canned text, optionally after a delay and
/// optionally requesting one tool call first.
class FakeProvider implements LlmProvider {
  final String reply;
  final Duration delay;
  final List<String> streamTokens;

  /// If set, the first complete() call requests this tool, the second
  /// returns [reply].
  final ToolCall? toolCall;
  int completeCalls = 0;

  FakeProvider({
    this.reply = 'Hello from the agent',
    this.delay = Duration.zero,
    this.streamTokens = const ['Hel', 'lo'],
    this.toolCall,
  });

  @override
  String get name => 'fake';

  @override
  Future<ProviderResult> complete({
    required List<Message> messages,
    List<GenesisTool> tools = const [],
    double temperature = 0.7,
  }) async {
    completeCalls++;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (toolCall != null && completeCalls == 1) {
      return ToolCallResult(toolCall!);
    }
    return TextResult(reply);
  }

  @override
  Stream<String> stream({
    required List<Message> messages,
    double temperature = 0.7,
  }) async* {
    for (final token in streamTokens) {
      if (delay > Duration.zero) await Future<void>.delayed(delay);
      yield token;
    }
  }
}

/// Provider whose complete() always throws.
class BrokenProvider implements LlmProvider {
  @override
  String get name => 'broken';

  @override
  Future<ProviderResult> complete({
    required List<Message> messages,
    List<GenesisTool> tools = const [],
    double temperature = 0.7,
  }) async => throw Exception('network down');

  @override
  Stream<String> stream({
    required List<Message> messages,
    double temperature = 0.7,
  }) => throw Exception('network down');
}
