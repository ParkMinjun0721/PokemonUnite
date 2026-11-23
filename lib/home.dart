import 'package:flutter/material.dart';
import 'pokemon/playername.dart';
import 'team/teamassign.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('포켓몬 유나이트',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(color: colors.primary)),
                        const SizedBox(height: 6),
                        Semantics(
                            header: true,
                            child: Text('내전 매니저',
                                style: theme.textTheme.displaySmall
                                    ?.copyWith(fontWeight: FontWeight.w800))),
                      ],
                    )),
                    const SizedBox(width: 12),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'images/suzy3.jpeg',
                          width: 88,
                          height: 88,
                          excludeFromSemantics: true,
                        )),
                  ]),
                  const SizedBox(height: 28),
                  _HomeAction(
                    label: '10명을 두 팀으로 나누기',
                    detail: '참가자 10명을 무작위로 5명씩 편성합니다.',
                    icon: Icons.groups_outlined,
                    color: colors.primaryContainer,
                    ink: colors.onPrimaryContainer,
                    page: const TeamAssignmentPage(),
                  ),
                  const SizedBox(height: 12),
                  _HomeAction(
                    label: '정해진 팀에 포켓몬 배정',
                    detail: '팀별 명단을 입력하고 배정 방식을 고릅니다.',
                    icon: Icons.catching_pokemon,
                    color: colors.secondaryContainer,
                    ink: colors.onSecondaryContainer,
                    page: const PlayerNamePage(),
                  ),
                  const SizedBox(height: 28),
                  SelectionArea(
                    child: Text('제작 님블  ·  문의 pmjunasd@gmail.com',
                        style: theme.textTheme.bodySmall),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeAction extends StatelessWidget {
  const _HomeAction(
      {required this.label,
      required this.detail,
      required this.icon,
      required this.color,
      required this.ink,
      required this.page});
  final String label, detail;
  final IconData icon;
  final Color color, ink;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Semantics(
          button: true,
          child: InkWell(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (_) => page)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(icon, color: ink),
                          Icon(Icons.arrow_forward, color: ink),
                        ]),
                    const SizedBox(height: 14),
                    Text(label,
                        style: theme.textTheme.titleLarge?.copyWith(
                            color: ink, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(detail,
                        style:
                            theme.textTheme.bodyMedium?.copyWith(color: ink)),
                  ]),
            ),
          )),
    );
  }
}
