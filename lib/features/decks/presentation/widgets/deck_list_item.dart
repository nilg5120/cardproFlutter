import 'package:cardpro/core/di/injection_container.dart';
import 'package:cardpro/db/database.dart';
import 'package:cardpro/features/decks/domain/entities/container.dart' as deck_entity;
import 'package:cardpro/features/decks/presentation/bloc/deck_bloc.dart';
import 'package:cardpro/features/decks/presentation/bloc/deck_event.dart';
import 'package:cardpro/features/decks/presentation/pages/deck_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeckListItem extends StatelessWidget {
  final deck_entity.Container deck;
  final VoidCallback onDelete;

  const DeckListItem({
    super.key,
    required this.deck,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DeckDetailPage(deck: deck),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      deck.name ?? 'Deck ${deck.id}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      if (deck.isActive)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Chip(
                            avatar: const Icon(Icons.check, size: 16),
                            label: const Text('使用中'),
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('使用中にする'),
                            onPressed: () => _onSetActivePressed(context),
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _showDeleteDialog(context),
                      ),
                    ],
                  ),
                ],
              ),
              if (deck.description != null) ...[
                const SizedBox(height: 8),
                Text('Description: ${deck.description}'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deck'),
        content: const Text('Are you sure you want to delete this deck?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _onSetActivePressed(BuildContext context) async {
    final db = sl<AppDatabase>();
    final currentActiveId = await db.getActiveDeckId();

    // If no active deck or already active target, just activate
    if (currentActiveId == null || currentActiveId == deck.id) {
      // ignore: use_build_context_synchronously
      context.read<DeckBloc>().add(SetActiveDeckEvent(id: deck.id));
      return;
    }

    // Load cards in target and active decks
    final targetCards = await db.getCardsInDeck(deck.id);
    final activeCards = await db.getCardsInDeck(currentActiveId);

    // Find overlapping instances by instance id
    final activeInstanceIds = activeCards.map((e) => e.$2.id).toSet();
    final overlaps = targetCards
        .where((e) => activeInstanceIds.contains(e.$2.id))
        .toList();

    if (overlaps.isEmpty) {
      // ignore: use_build_context_synchronously
      context.read<DeckBloc>().add(SetActiveDeckEvent(id: deck.id));
      return;
    }

    // Prepare display rows with source (active deck name + location)
    final activeDeckRow = await (db.select(db.containers)
          ..where((t) => t.id.equals(currentActiveId)))
        .getSingleOrNull();
    final sourceDeckName = activeDeckRow?.name ?? 'Deck $currentActiveId';

    // Map active deck by instance id to get location
    final activeByInstanceId = <int, (MtgCard, CardInstance, ContainerCardLocation)>{
      for (final a in activeCards) a.$2.id: a,
    };

    // Deduplicate by card name for concise display
    final seenNames = <String>{};
    final displayList = <({String name, String source})>[];
    for (final t in overlaps) {
      final nm = t.$1.name;
      if (seenNames.add(nm)) {
        final src = activeByInstanceId[t.$2.id]?.$3.location;
        final srcText = src != null && src.isNotEmpty
            ? '$sourceDeckName ($src)'
            : sourceDeckName;
        displayList.add((name: nm, source: srcText));
      }
    }

    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('カードの移動が必要です'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("現在使用中のデッキから以下のカードを\n${deck.name ?? '選択したデッキ'} へ移動してください。"),
                const SizedBox(height: 12),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: displayList.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final row = displayList[i];
                        return ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          leading: const Icon(Icons.arrow_right),
                          title: Text(row.name),
                          subtitle: Text('移動元: ${row.source}'),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('移動が完了したら「移動完了」を押してください。'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('移動完了'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      context.read<DeckBloc>().add(SetActiveDeckEvent(id: deck.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('デッキを使用中に切り替えました')),
      );
    }
  }
}
