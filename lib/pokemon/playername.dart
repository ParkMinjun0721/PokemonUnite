import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';
import '../widgets/roster_form.dart';
import 'pokemon_category_page.dart';

class PlayerNamePage extends ConsumerWidget {
  const PlayerNamePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RosterForm(
      fixedTeams: true,
      players: ref.watch(playerProvider),
      onChanged: ref.read(playerProvider.notifier).updatePlayer,
      onReplace: ref.read(playerProvider.notifier).replacePlayers,
      onContinue: (names) => Navigator.of(context).push(
        MaterialPageRoute<void>(
            builder: (_) => PokemonCategoryPage(players: names)),
      ),
    );
  }
}
