import 'package:flutter/material.dart';

class LabeledProgressIndicator extends StatelessWidget {
  final double value;
  final String semanticLabel;
  final String semanticValue;

  const LabeledProgressIndicator({
    super.key,
    required this.value,
    required this.semanticLabel,
    required this.semanticValue,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      value: semanticValue,
      child: LinearProgressIndicator(
        value: value,
        minHeight: 8,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
