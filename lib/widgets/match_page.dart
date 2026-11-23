import 'package:flutter/material.dart';

/// Keeps actions within the same reading width as the content. When the
/// keyboard or large text leaves little height, the actions scroll with it.
class MatchPage extends StatelessWidget {
  const MatchPage({
    super.key,
    required this.title,
    required this.child,
    this.action,
    this.maxWidth = 620,
  });

  final String title;
  final Widget child;
  final Widget? action;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: LayoutBuilder(builder: (context, bounds) {
              final pinAction = bounds.maxHeight >=
                  380 * MediaQuery.textScalerOf(context).scale(1);
              final footer = Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: action,
              );
              final content = Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: child,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          content,
                          if (!pinAction && action != null) footer
                        ],
                      ),
                    ),
                  ),
                  if (pinAction && action != null) footer,
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class TeamHeading extends StatelessWidget {
  const TeamHeading(this.number, {super.key});
  final int number;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      header: true,
      child: Text('$number팀',
          style: theme.textTheme.titleLarge?.copyWith(
            color: number == 1
                ? theme.colorScheme.primary
                : theme.colorScheme.secondary,
            fontWeight: FontWeight.bold,
          )),
    );
  }
}
