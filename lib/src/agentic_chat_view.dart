import 'package:flutter/material.dart';

import 'chat_bubble.dart';
import 'chat_controller.dart';
import 'chat_input_bar.dart';
import 'chat_theme.dart';

/// A complete chat screen for a [AgenticChatController]: scrolling message
/// list, live streaming bubbles, ReAct step trails, and an input bar.
///
/// ```dart
/// Scaffold(
///   appBar: AppBar(title: const Text('Assistant')),
///   body: AgenticChatView(controller: controller),
/// )
/// ```
class AgenticChatView extends StatefulWidget {
  final AgenticChatController controller;
  final AgenticChatTheme theme;

  /// Stream replies token-by-token instead of running the full tool loop.
  final bool streamResponses;

  /// Show ReAct step trails above agent replies.
  final bool showSteps;

  /// Shown when there are no messages yet.
  final Widget? emptyState;

  final String inputHint;

  const AgenticChatView({
    super.key,
    required this.controller,
    this.theme = const AgenticChatTheme(),
    this.streamResponses = false,
    this.showSteps = true,
    this.emptyState,
    this.inputHint = 'Message…',
  });

  @override
  State<AgenticChatView> createState() => _AgenticChatViewState();
}

class _AgenticChatViewState extends State<AgenticChatView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(AgenticChatView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChanged);
      widget.controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {});
    // Keep the newest message in view as tokens arrive.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.controller.messages;
    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: widget.emptyState ??
                      Text(
                        'Send a message to start',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                      ),
                )
              : ListView.builder(
                  key: const Key('agentic_chat_list'),
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) => ChatBubble(
                    message: messages[index],
                    theme: widget.theme,
                    showSteps: widget.showSteps,
                  ),
                ),
        ),
        ChatInputBar(
          enabled: !widget.controller.isBusy,
          hintText: widget.inputHint,
          onSend: (text) =>
              widget.controller.send(text, stream: widget.streamResponses),
        ),
      ],
    );
  }
}
