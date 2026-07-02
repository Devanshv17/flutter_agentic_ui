import 'package:flutter/material.dart';
import 'package:flutter_agentic/flutter_agentic.dart';

/// Renders the ReAct steps behind an agent reply — thinking, tool calls,
/// tool results — as a compact expandable trail.
class AgentStepsView extends StatelessWidget {
  final List<AgentStep> steps;

  /// Start expanded instead of collapsed.
  final bool initiallyExpanded;

  const AgentStepsView({
    super.key,
    required this.steps,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final visible = steps.where((s) => s is! FinalResponseStep).toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    final toolCalls = visible.whereType<ToolCallStep>().length;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: const Key('agentic_steps_tile'),
        initiallyExpanded: initiallyExpanded,
        tilePadding: EdgeInsets.zero,
        dense: true,
        title: Text(
          toolCalls > 0
              ? '$toolCalls tool call${toolCalls == 1 ? '' : 's'}'
              : '${visible.length} step${visible.length == 1 ? '' : 's'}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        children: visible.map((s) => _StepRow(step: s)).toList(),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final AgentStep step;
  const _StepRow({required this.step});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (icon, text, color) = switch (step) {
      ThinkingStep(:final thought) => (Icons.psychology_alt_outlined, thought, scheme.onSurfaceVariant),
      ToolCallStep s => (Icons.build_outlined, s.displayText, scheme.primary),
      ToolResultStep s => (Icons.check_circle_outline, '${s.toolName} → ${s.displayText}', scheme.tertiary),
      ErrorStep(:final message) => (Icons.error_outline, message, scheme.error),
      FinalResponseStep(:final text) => (Icons.chat_bubble_outline, text, scheme.onSurface),
    };
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: color),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
