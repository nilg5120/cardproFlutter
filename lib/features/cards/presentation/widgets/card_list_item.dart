import 'package:flutter/material.dart';
import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';

class CardListItem extends StatelessWidget {
  final CardWithInstance card;
  final VoidCallback onDelete;
  final Function(String) onEdit;

  const CardListItem({
    super.key,
    required this.card,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    card.card.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditDialog(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteDialog(context),
                    ),
                  ],
                ),
              ],
            ),
            if (card.card.rarity != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('レアリティ: ${card.card.rarity}'),
              ),
            if (card.card.setName != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('セット: ${card.card.setName}'),
              ),
            if (card.card.cardNumber != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('カード番号: ${card.card.cardNumber}'),
              ),
            if (card.instance.description != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('メモ: ${card.instance.description}'),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('カードを削除'),
        content: const Text('このカードを削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(
      text: card.instance.description ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('メモを編集'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'メモを入力してください',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onEdit(controller.text);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
