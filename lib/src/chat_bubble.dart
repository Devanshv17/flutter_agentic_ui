import 'package:flutter/material.dart';

import 'agent_steps_view.dart';
import 'chat_controller.dart';
import 'chat_theme.dart';
import 'typing_indicator.dart';

/// One message bubble — user right/primary, agent left/surface. Shows a
/// [TypingIndicator] while the reply is pending, the step trail when the
/// agent used tools, and error styling for failed turns.
class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final AgenticChatTheme theme;

  /// Show the ReAct step trail above agent replies (default true).
  final bool showSteps;

  const ChatBubble({
    super.key,
    required this.message,
    this.theme = const AgenticChatTheme(),
    this.showSteps = true,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final isError = message.status == ChatMessageStatus.error;
    final waiting =
        !isUser &&
        message.text.isEmpty &&
        (message.status == ChatMessageStatus.sending ||
            message.status == ChatMessageStatus.streaming);

    final background =
        isError
            ? theme.resolvedError(context).withValues(alpha: 0.12)
            : isUser
            ? theme.resolvedUserBubble(context)
            : theme.resolvedAgentBubble(context);
    final foreground =
        isError
            ? theme.resolvedError(context)
            : isUser
            ? theme.resolvedUserText(context)
            : theme.resolvedAgentText(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isUser && showSteps && message.steps.isNotEmpty)
              AgentStepsView(steps: message.steps),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 3),
              padding: theme.bubblePadding,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(theme.bubbleRadius),
                  topRight: Radius.circular(theme.bubbleRadius),
                  bottomLeft: Radius.circular(isUser ? theme.bubbleRadius : 4),
                  bottomRight: Radius.circular(isUser ? 4 : theme.bubbleRadius),
                ),
              ),
              child:
                  waiting
                      ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: TypingIndicator(),
                      )
                      : SelectableText(
                        message.text,
                        style: TextStyle(color: foreground),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
