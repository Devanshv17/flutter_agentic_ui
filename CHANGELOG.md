# Changelog

## [0.1.1] — 2026-07-02

- Formatted with `dart format` for full pub.dev static-analysis score. No functional changes.

## [0.1.0] — 2026-07-02

Initial release.

- `AgenticChatController` — `ChangeNotifier` driving a `GenesisAgent`: `send()` (full ReAct turn with live step updates) and `send(stream: true)` (token streaming), `isBusy`, `clear()`, `loadHistory()`.
- `AgenticChatView` — complete chat screen with auto-scroll, empty state, and input bar.
- `ChatBubble` — user/agent bubbles, error styling, typing indicator while waiting.
- `AgentStepsView` — expandable ReAct step trail (thinking / tool calls / results).
- `ChatInputBar` — send on button or keyboard action, disabled while busy.
- `TypingIndicator` — animated three-dot indicator.
- `AgenticChatTheme` — colors and bubble shape, defaulting to the ambient Material theme.
