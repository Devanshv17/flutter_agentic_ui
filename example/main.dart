// Example: a complete AI chat screen in one file.
import 'package:flutter/material.dart';
import 'package:flutter_agentic/flutter_agentic.dart';
import 'package:flutter_agentic_ui/flutter_agentic_ui.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
    home: const ChatScreen(),
  );
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final AgenticChatController controller = AgenticChatController(
    agent: AgenticAgent(
      provider: GeminiProvider(apiKey: 'YOUR_GEMINI_API_KEY'),
      systemPrompt: 'You are a friendly assistant.',
      tools: AgenticTools.all, // calculator, date/time, http, weather
    ),
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: controller.clear,
          ),
        ],
      ),
      body: AgenticChatView(
        controller: controller,
        // streamResponses: true, // token-by-token mode
      ),
    );
  }
}
