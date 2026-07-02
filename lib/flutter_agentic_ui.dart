/// flutter_agentic_ui — drop-in chat UI for Flutter AI agents.
///
/// An [AgenticChatController] that drives a `AgenticAgent`, plus ready-made
/// widgets: full chat view, message bubbles with streaming, a ReAct step
/// visualizer, typing indicator, and input bar.
///
/// ```dart
/// import 'package:flutter_agentic_ui/flutter_agentic_ui.dart';
///
/// final controller = AgenticChatController(agent: agent);
/// // ...
/// AgenticChatView(controller: controller)
/// ```
library;

export 'src/agent_steps_view.dart';
export 'src/agentic_chat_view.dart';
export 'src/chat_bubble.dart';
export 'src/chat_controller.dart';
export 'src/chat_input_bar.dart';
export 'src/chat_theme.dart';
export 'src/typing_indicator.dart';
