import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:flutter/material.dart';


/// カードリストの各アイテムを表示するウィジェット
class CardListItem extends StatelessWidget {
  final CardWithInstance card;
  final VoidCallback onDelete;
  final Function(String, {String? rarity, String? setName, int? cardNumber})
      onEdit;
  final VoidCallback? onTap;
  final bool showDelete;
  final bool showSetName;
  final bool showCardName;
  // タイトルウィジェットの上書きを許可（例: ローカライズ済み名称）
  final Widget? title;
  // グループ表示用の任意カウントバッジ
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
                          // 任意のセット名
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
                        label: Text('$count枚'),
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Memo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Memo',
            border: OutlineInputBorder(),
            hintText: 'Enter a note',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onEdit(controller.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _buildPlacementSummary() {
    if (card.placements.isEmpty) {
      return '未割り当て';
    }

    return card.placements.map((placement) {
      final name = (placement.containerName != null &&
              placement.containerName!.trim().isNotEmpty)
          ? placement.containerName!.trim()
          : (placement.containerType != null &&
                  placement.containerType!.trim().isNotEmpty)
              ? placement.containerType!.trim()
              : '不明なコンテナ';
      return '$name (${placement.location})';
    }).join(', ');
  }
}



