import 'package:flutter/foundation.dart';
import 'package:flutter_agentic/flutter_agentic.dart';

/// The lifecycle of one message bubble.
enum ChatMessageStatus { sending, streaming, complete, error }

/// UI model for one message in the chat.
class ChatMessage {
  final String id;
  final bool isUser;
  final String text;
  final ChatMessageStatus status;

  /// ReAct steps the agent took while producing this message (tool calls,
  /// results, thinking). Empty for user messages and plain replies.
  final List<AgentStep> steps;

  const ChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    this.status = ChatMessageStatus.complete,
    this.steps = const [],
  });

  ChatMessage copyWith({
    String? text,
    ChatMessageStatus? status,
    List<AgentStep>? steps,
  }) =>
      ChatMessage(
        id: id,
        isUser: isUser,
        text: text ?? this.text,
        status: status ?? this.status,
        steps: steps ?? this.steps,
      );
}

/// Drives a chat conversation with a [GenesisAgent] and exposes it as
/// observable UI state. Attach it to an [AgenticChatView], or listen to it
/// yourself and build any UI you like.
///
/// ```dart
/// final controller = AgenticChatController(agent: agent);
/// await controller.send('Hello!');            // full ReAct turn (tools work)
/// await controller.send('Hi', stream: true);  // token-by-token streaming
/// ```
class AgenticChatController extends ChangeNotifier {
  final GenesisAgent agent;

  final List<ChatMessage> _messages = [];
  bool _busy = false;
  bool _disposed = false;
  int _nextId = 0;

  AgenticChatController({required this.agent});

  /// All messages, oldest first.
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  /// True while a send is in flight — use it to disable the input bar.
  bool get isBusy => _busy;

  /// Sends [text] to the agent.
  ///
  /// With [stream] true the reply arrives token by token (no tool calls);
  /// otherwise the full ReAct loop runs and tool steps are recorded on the
  /// reply message as they happen.
  Future<void> send(String text, {bool stream = false}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _busy) return;
    _busy = true;

    _messages.add(ChatMessage(
        id: _id(), isUser: true, text: trimmed));
    final reply = ChatMessage(
      id: _id(),
      isUser: false,
      text: '',
      status: stream ? ChatMessageStatus.streaming : ChatMessageStatus.sending,
    );
    _messages.add(reply);
    _notify();

    try {
      if (stream) {
        var acc = '';
        await for (final token in agent.chatStream(trimmed)) {
          acc += token;
          _update(reply.id, (m) => m.copyWith(text: acc));
        }
        _update(reply.id,
            (m) => m.copyWith(status: ChatMessageStatus.complete));
      } else {
        final steps = <AgentStep>[];
        final response = await agent.chat(trimmed, onStep: (step) {
          steps.add(step);
          _update(reply.id, (m) => m.copyWith(steps: List.of(steps)));
        });
        final (replyText, status) = switch (response) {
          TextAgentResponse(:final text) => (text, ChatMessageStatus.complete),
          MaxIterationsResponse() => (
              'The agent could not finish within its step limit.',
              ChatMessageStatus.error
            ),
          ErrorAgentResponse(:final message) => (
              message,
              ChatMessageStatus.error
            ),
        };
        _update(reply.id, (m) => m.copyWith(text: replyText, status: status));
      }
    } catch (e) {
      _update(
          reply.id,
          (m) =>
              m.copyWith(text: 'Error: $e', status: ChatMessageStatus.error));
    } finally {
      _busy = false;
      _notify();
    }
  }

  /// Clears the visible messages and the agent's persisted history.
  Future<void> clear() async {
    _messages.clear();
    await agent.clearHistory();
    _notify();
  }

  /// Loads previously persisted history into the visible message list.
  Future<void> loadHistory() async {
    final history = await agent.getHistory();
    _messages
      ..clear()
      ..addAll(history
          .where((m) =>
              m.role == MessageRole.user || m.role == MessageRole.assistant)
          .map((m) => ChatMessage(
                id: _id(),
                isUser: m.role == MessageRole.user,
                text: m.content,
              )));
    _notify();
  }

  String _id() => 'msg_${_nextId++}';

  void _update(String id, ChatMessage Function(ChatMessage) transform) {
    final index = _messages.indexWhere((m) => m.id == id);
    if (index == -1) return;
    _messages[index] = transform(_messages[index]);
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
