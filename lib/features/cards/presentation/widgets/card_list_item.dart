import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:cardpro/core/di/injection_container.dart';
import 'package:cardpro/db/database.dart' as db;
import 'package:flutter/material.dart';

/// Renders a single row in the card instance list.
class CardListItem extends StatelessWidget {
  final CardWithInstance card;
  final VoidCallback onDelete;
  final void Function(String, {int? containerId, String? rarity, String? setName, int? cardNumber}) onEdit;
  final VoidCallback? onTap;
  final bool showDelete;
  final bool showSetName;
  final bool showCardName;
  final Widget? title;
  final int? count;

  const CardListItem({
    super.key,
    required this.card,
    required this.onDelete,
    required this.onEdit,
    this.onTap,
    this.showDelete = true,
    this.showSetName = true,
    this.showCardName = true,
    this.title,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final description = card.instance.description?.trim();
    final hasDescription = description != null && description.isNotEmpty;
    final placementSummary = _buildPlacementSummary();
    final hasPlacementSummary = placementSummary.isNotEmpty;
    final showHeaderRow = showCardName || showSetName || title != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap ?? () => _showEditDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showHeaderRow)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showCardName)
                            Flexible(
                              fit: FlexFit.tight,
                              child: title ??
                                  Text(
                                    card.card.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            )
                          else if (title != null)
                            Flexible(
                              fit: FlexFit.tight,
                              child: title!,
                            ),
                          if (showCardName) const SizedBox(width: 12),
                          if (showSetName && card.card.setName != null)
                            Flexible(
                              child: Text(
                                card.card.setName!,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.grey[700]),
                              ),
                            ),
                        ],
                      ),
                    if (hasPlacementSummary)
                      Padding(
                        padding: EdgeInsets.only(top: showHeaderRow ? 8 : 0),
                        child: Text(
                          placementSummary,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ),
                    if (hasDescription)
                      Padding(
                        padding: EdgeInsets.only(
                          top: (hasPlacementSummary || showHeaderRow) ? 8 : 0,
                        ),
                        child: Text(
                          description,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey[800]),
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (count != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Chip(
                        label: Text('$count\u679a'),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  if (showDelete)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteDialog(context),
                    ),
                ],
              ),
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
        title: const Text('Delete Card'),
        content: const Text('Are you sure you want to delete this card?'),
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

  void _showEditDialog(BuildContext context) {
    final controller =
        TextEditingController(text: card.instance.description ?? '');
    final initialPlacement =
        card.placements.isNotEmpty ? card.placements.first : null;
    int? selectedContainerId = initialPlacement?.containerId;
    final database = sl<db.AppDatabase>();
    final containerFuture =
        database.select(database.containers).get();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return FutureBuilder<List<db.Container>>(
          future: containerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                title: Text('Edit Card'),
                content: SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final containers = snapshot.data ?? <db.Container>[];
            final availableIds = containers.map((c) => c.id).toSet();
            if (selectedContainerId != null &&
                !availableIds.contains(selectedContainerId)) {
              selectedContainerId = null;
            }

            final loadError = snapshot.error;

            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: const Text('Edit Card'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: 'Memo',
                          border: OutlineInputBorder(),
                          hintText: 'Enter a note',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int?>(
                        initialValue: selectedContainerId,
                        decoration: const InputDecoration(
                          labelText: 'Container',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child:
                                Text('\u672a\u5272\u308a\u5f53\u3066'),
                          ),
                          ...containers.map(
                            (container) => DropdownMenuItem<int?>(
                              value: container.id,
                              child: Text(_formatContainerLabel(container)),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedContainerId = value;
                          });
                        },
                      ),
                      if (loadError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '\u30b3\u30f3\u30c6\u30ca\u4e00\u89a7\u306e\u53d6\u5f97\u306b\u5931\u6557\u3057\u307e\u3057\u307e\u3057\u305f',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        onEdit(
                          controller.text,
                          containerId: selectedContainerId,
                        );
                      },
                      child: const Text('Save'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  String _formatContainerLabel(db.Container container) {
    final rawName = container.name?.trim();
    final displayName = (rawName != null && rawName.isNotEmpty)
        ? rawName
        : 'Container ${container.id}';
    final type = container.containerType.trim();
    return '$displayName ($type)';
  }

  String _buildPlacementSummary() {
    if (card.placements.isEmpty) {
      return '\u672a\u5272\u308a\u5f53\u3066';
    }

    final summary = card.placements
        .map((placement) => placement.location.trim())
        .where((location) => location.isNotEmpty)
        .join(', ');

    return summary.isNotEmpty ? summary : '\u672a\u5272\u308a\u5f53\u3066';
  }
}
