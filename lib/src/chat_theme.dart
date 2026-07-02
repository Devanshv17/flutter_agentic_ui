import 'package:flutter/material.dart';

/// Visual customisation for the chat widgets. Every field is optional —
/// unset values fall back to the ambient [ThemeData].
class AgenticChatTheme {
  final Color? userBubbleColor;
  final Color? agentBubbleColor;
  final Color? userTextColor;
  final Color? agentTextColor;
  final Color? errorColor;
  final double bubbleRadius;
  final EdgeInsets bubblePadding;

  const AgenticChatTheme({
    this.userBubbleColor,
    this.agentBubbleColor,
    this.userTextColor,
    this.agentTextColor,
    this.errorColor,
    this.bubbleRadius = 16,
    this.bubblePadding =
        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  });

  Color resolvedUserBubble(BuildContext context) =>
      userBubbleColor ?? Theme.of(context).colorScheme.primary;

  Color resolvedAgentBubble(BuildContext context) =>
      agentBubbleColor ?? Theme.of(context).colorScheme.surfaceContainerHighest;

  Color resolvedUserText(BuildContext context) =>
      userTextColor ?? Theme.of(context).colorScheme.onPrimary;

  Color resolvedAgentText(BuildContext context) =>
      agentTextColor ?? Theme.of(context).colorScheme.onSurface;

  Color resolvedError(BuildContext context) =>
      errorColor ?? Theme.of(context).colorScheme.error;
}
