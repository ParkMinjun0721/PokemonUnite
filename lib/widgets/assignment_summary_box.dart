import 'package:flutter/material.dart';

class AssignmentSummaryBox extends StatelessWidget {
  final String semanticLabel;
  final String summary;
  final IconData icon;

  const AssignmentSummaryBox({
    super.key,
    required this.semanticLabel,
    required this.summary,
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      value: summary,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  summary,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
