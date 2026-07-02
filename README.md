# flutter_agentic_ui — Chat UI for Flutter AI Agents

[![pub package](https://img.shields.io/pub/v/flutter_agentic_ui.svg)](https://pub.dev/packages/flutter_agentic_ui)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)

**A drop-in chat screen for your AI agent.** Message list with streaming bubbles, a ReAct tool-call visualizer, typing indicator, and input bar — wired directly to a [flutter_agentic](https://pub.dev/packages/flutter_agentic) `AgenticAgent` through one observable controller.

👉 **[View on pub.dev](https://pub.dev/packages/flutter_agentic_ui)** · [API docs](https://pub.dev/documentation/flutter_agentic_ui/latest/) · [GitHub](https://github.com/Devanshv17/flutter_agentic_ui)

Part of the **flutter_agentic** family: [flutter_agentic](https://pub.dev/packages/flutter_agentic) (core SDK) · [flutter_agentic_graph](https://pub.dev/packages/flutter_agentic_graph) · [flutter_agentic_tools](https://pub.dev/packages/flutter_agentic_tools) · [flutter_agentic_memory](https://pub.dev/packages/flutter_agentic_memory)

---

## Installation

```yaml
dependencies:
  flutter_agentic_ui: ^0.1.1
```

## A full agent chat screen in ~15 lines

```dart
import 'package:flutter_agentic/flutter_agentic.dart';
import 'package:flutter_agentic_ui/flutter_agentic_ui.dart';

class ChatScreen extends StatefulWidget { /* ... */ }

class _ChatScreenState extends State<ChatScreen> {
  late final controller = AgenticChatController(
    agent: AgenticAgent(
      provider: GeminiProvider(apiKey: 'YOUR_KEY'),
      tools: AgenticTools.all,
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Assistant')),
        body: AgenticChatView(controller: controller),
      );

  @override
  void dispose() { controller.dispose(); super.dispose(); }
}
```

That's it — tool calls, the typing indicator, error bubbles, and auto-scroll all work out of the box.

## What you get

| Widget | Purpose |
|---|---|
| `AgenticChatView` | complete chat screen: list + input bar + auto-scroll |
| `AgenticChatController` | `ChangeNotifier` driving the conversation; use it with any custom UI |
| `ChatBubble` | one message — user/agent styling, error state, typing indicator while waiting |
| `AgentStepsView` | expandable "2 tool calls" trail showing the agent's ReAct steps |
| `ChatInputBar` | text field + send button, disables itself while the agent works |
| `TypingIndicator` | the classic three animated dots |

## Streaming replies

```dart
AgenticChatView(controller: controller, streamResponses: true)
// or directly: controller.send('Tell me a story', stream: true);
```

Tokens render into the bubble as they arrive.

## See what the agent did

Replies produced with tools show a collapsible step trail — thinking, each tool call with its arguments, and each result:

```
▸ 2 tool calls
   🔧 get_weather(city: Tokyo)
   ✅ get_weather → {"temp": 23}
   🔧 calculator(expression: 100^0.5)
   ✅ calculator → {"result": 10}
```

Hide it with `showSteps: false`, or embed `AgentStepsView(steps: ...)` anywhere yourself.

## Theming

```dart
AgenticChatView(
  controller: controller,
  theme: AgenticChatTheme(
    userBubbleColor: Colors.indigo,
    bubbleRadius: 20,
  ),
)
```

Unset values follow your app's `ThemeData` (Material 3 color scheme).

## Bring your own UI

`AgenticChatController` is just a `ChangeNotifier` with `messages`, `isBusy`, `send()`, `clear()`, and `loadHistory()` — drive any custom layout from it and skip the bundled widgets entirely.

## License

MIT — see [LICENSE](LICENSE).
