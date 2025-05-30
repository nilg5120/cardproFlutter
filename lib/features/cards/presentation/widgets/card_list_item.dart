import 'package:flutter/material.dart';
import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';

class CardListItem extends StatelessWidget {
  final CardWithInstance card;
  final VoidCallback onDelete;
  final Function(String, {String? rarity, String? setName, int? cardNumber}) onEdit;

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

  // カード情報編集ダイアログを表示
  void _showEditDialog(BuildContext context) {
    final descriptionController = TextEditingController(
      text: card.instance.description ?? '',
    );
    final nameController = TextEditingController(
      text: card.card.name,
    );
    final rarityController = TextEditingController(
      text: card.card.rarity ?? '',
    );
    final setNameController = TextEditingController(
      text: card.card.setName ?? '',
    );
    final cardNumberController = TextEditingController(
      text: card.card.cardNumber?.toString() ?? '',
    );

    // 変更されたかどうかを追跡するフラグ
    bool rarityChanged = false;
    bool setNameChanged = false;
    bool cardNumberChanged = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('カード情報を編集'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'カード名',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true, // カード名は編集不可
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: rarityController,
                    decoration: const InputDecoration(
                      labelText: 'レアリティ',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        rarityChanged = true;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: setNameController,
                    decoration: const InputDecoration(
                      labelText: '拡張パック名',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        setNameChanged = true;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cardNumberController,
                    decoration: const InputDecoration(
                      labelText: 'カード番号',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        cardNumberChanged = true;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'メモ',
                      border: OutlineInputBorder(),
                      hintText: 'メモを入力してください',
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
                  
                  // 変更されたフィールドのみを渡す
                  final String? rarity = rarityChanged ? rarityController.text.isEmpty ? null : rarityController.text : null;
                  final String? setName = setNameChanged ? setNameController.text.isEmpty ? null : setNameController.text : null;
                  final int? cardNumber = cardNumberChanged ? int.tryParse(cardNumberController.text) : null;
                  
                  if (rarityChanged || setNameChanged || cardNumberChanged) {
                    onEdit(
                      descriptionController.text,
                      rarity: rarity,
                      setName: setName,
                      cardNumber: cardNumber,
                    );
                  } else {
                    onEdit(descriptionController.text);
                  }
                },
                child: const Text('保存'),
              ),
            ],
          );
        },
      ),
    );
  }
}
