import 'package:flutter/material.dart';
import 'package:cardpro/features/decks/domain/entities/container.dart' as deck_entity;

class DeckListItem extends StatelessWidget {
  final deck_entity.Container deck;
  final VoidCallback onDelete;
  final Function(String?, String?) onEdit;

  const DeckListItem({
    super.key,
    required this.deck,
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
                    deck.name ?? 'デッキ ${deck.id}',
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
            if (deck.description != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('説明: ${deck.description}'),
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
        title: const Text('デッキを削除'),
        content: const Text('このデッキを削除してもよろしいですか？'),
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
    final descriptionController = TextEditingController(
      text: deck.description ?? '',
    );
    final nameController = TextEditingController(
      text: deck.name ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('デッキ情報を編集'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'デッキ名',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '説明',
                  border: OutlineInputBorder(),
                  hintText: '説明を入力してください',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 現在のBlocの実装では編集機能がないため、
              // 将来的に実装される編集機能に対応できるようにしておく
              onEdit(
                nameController.text.isEmpty ? null : nameController.text,
                descriptionController.text.isEmpty ? null : descriptionController.text
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
