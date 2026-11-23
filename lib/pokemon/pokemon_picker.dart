import 'package:flutter/material.dart';

class PokemonPicker extends StatefulWidget {
  const PokemonPicker({
    super.key,
    required this.candidates,
    required this.selected,
    required this.onChanged,
    required this.onClear,
    required this.listLabel,
  });

  final List<Map<String, String>> candidates;
  final Set<String> selected;
  final void Function(String, bool) onChanged;
  final VoidCallback onClear;
  final String listLabel;

  @override
  State<PokemonPicker> createState() => _PokemonPickerState();
}

class _PokemonPickerState extends State<PokemonPicker> {
  final search = TextEditingController();
  bool showSelected = false;

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Widget _options(Iterable<Map<String, String>> options) {
    return Wrap(spacing: 8, runSpacing: 4, children: [
      for (final pokemon in options)
        FilterChip(
          label: Text(pokemon['name']!),
          selected: widget.selected.contains(pokemon['name']),
          onSelected: (enabled) => widget.onChanged(pokemon['name']!, enabled),
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final query = search.text.trim().toLowerCase();
    final candidates = widget.candidates;
    final matches =
        candidates.where((p) => p['name']!.toLowerCase().contains(query));
    final roles = candidates.map((p) => p['category']!).toSet();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TextField(
        controller: search,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: '포켓몬 검색',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: search.text.isEmpty
              ? null
              : IconButton(
                  tooltip: '검색어 지우기',
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(search.clear),
                ),
        ),
      ),
      Wrap(alignment: WrapAlignment.spaceBetween, children: [
        TextButton.icon(
          onPressed: widget.selected.isEmpty && !showSelected
              ? null
              : () => setState(() => showSelected = !showSelected),
          icon: Icon(showSelected ? Icons.expand_less : Icons.expand_more),
          label: Text('${widget.listLabel} (${widget.selected.length})'),
        ),
        if (widget.selected.isNotEmpty)
          TextButton(onPressed: widget.onClear, child: const Text('전체 해제')),
      ]),
      if (showSelected)
        Wrap(spacing: 8, children: [
          for (final name in widget.selected)
            InputChip(
              label: Text(name),
              deleteButtonTooltipMessage: '$name 선택 해제',
              onDeleted: () => widget.onChanged(name, false),
            ),
        ]),
      if (query.isNotEmpty) ...[
        if (matches.isEmpty)
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('검색 결과가 없습니다. 다른 이름을 입력해 보세요.'))
        else
          _options(matches),
      ] else
        for (final role in roles)
          ExpansionTile(
            key: PageStorageKey(role),
            title: Text(role),
            expandedAlignment: Alignment.centerLeft,
            childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            children: [
              _options(candidates.where((p) => p['category'] == role))
            ],
          ),
    ]);
  }
}
