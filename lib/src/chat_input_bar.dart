import 'package:flutter/material.dart';

/// Text field + send button. Disables itself while [enabled] is false and
/// clears after sending.
class ChatInputBar extends StatefulWidget {
  final void Function(String text) onSend;
  final bool enabled;
  final String hintText;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.enabled = true,
    this.hintText = 'Message…',
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('agentic_chat_input'),
                controller: _controller,
                enabled: widget.enabled,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submit(),
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton.filled(
              key: const Key('agentic_chat_send'),
              onPressed: widget.enabled ? _submit : null,
              icon: const Icon(Icons.arrow_upward),
              tooltip: 'Send',
            ),
          ],
        ),
      ),
    );
  }
}
