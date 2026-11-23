import 'package:flutter/material.dart';
import '../widgets/match_page.dart';

class PokemonPortrait extends StatelessWidget {
  const PokemonPortrait(this.pokemon, {super.key, required this.size});

  final Map<String, String> pokemon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      pokemon['image']!,
      width: size,
      height: size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
      errorBuilder: (_, __, ___) => SizedBox.square(
        dimension: size,
        child: const Icon(Icons.catching_pokemon),
      ),
    );
  }
}

/// The same teams can be shown before and after assigning Pokémon.
class ResultsPage extends StatelessWidget {
  const ResultsPage({
    super.key,
    required this.team1,
    required this.team2,
    this.playerPokemonMap = const {},
  });

  final List<String> team1, team2;
  final Map<String, Map<String, String>> playerPokemonMap;

  Widget _team(BuildContext context, int number, List<String> players) {
    final theme = Theme.of(context);
    final color = number == 1
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.secondaryContainer;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(18),
        ),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            decoration: BoxDecoration(
                color: color,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(17))),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TeamHeading(number),
          ),
          for (final name in players)
            ListTile(
              leading: playerPokemonMap[name] == null
                  ? null
                  : PokemonPortrait(playerPokemonMap[name]!, size: 44),
              title: Text(name),
              subtitle: playerPokemonMap[name] == null
                  ? null
                  : Text(playerPokemonMap[name]!['name']!),
            ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final first = _team(context, 1, team1);
    final second = _team(context, 2, team2);
    return LayoutBuilder(builder: (context, bounds) {
      if (bounds.maxWidth >= 640 * MediaQuery.textScalerOf(context).scale(1)) {
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: first),
          const SizedBox(width: 16),
          Expanded(child: second),
        ]);
      }
      return Column(children: [first, const SizedBox(height: 16), second]);
    });
  }
}
