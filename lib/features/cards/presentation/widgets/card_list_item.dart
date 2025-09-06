import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:flutter/material.dart';

class CardListItem extends StatelessWidget {
  final CardWithInstance card;
  final VoidCallback onDelete;
  final Function(String, {String? rarity, String? setName, int? cardNumber})
      onEdit;

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
              const SizedBox(height: 8),
            if (card.card.rarity != null)
              Text('Rarity: ${card.card.rarity}'),
            if (card.card.setName != null)
              const SizedBox(height: 4),
            if (card.card.setName != null)
              Text('Set: ${card.card.setName}'),
            if (card.card.cardNumber != null)
              const SizedBox(height: 4),
            if (card.card.cardNumber != null)
              Text('Card No.: ${card.card.cardNumber}'),
            if (card.instance.description != null)
              const SizedBox(height: 8),
            if (card.instance.description != null)
              Text('Memo: ${card.instance.description}'),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
        content:
            const Text('Are you sure you want to delete this card?'),
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
    final descriptionController =
        TextEditingController(text: card.instance.description ?? '');
    final nameController = TextEditingController(text: card.card.name);
    final rarityController =
        TextEditingController(text: card.card.rarity ?? '');
    final setNameController =
        TextEditingController(text: card.card.setName ?? '');
    final cardNumberController = TextEditingController(
      text: card.card.cardNumber?.toString() ?? '',
    );

    bool rarityChanged = false;
    bool setNameChanged = false;
    bool cardNumberChanged = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Card Info'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: rarityController,
                    decoration: const InputDecoration(
                      labelText: 'Rarity',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => rarityChanged = true),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: setNameController,
                    decoration: const InputDecoration(
                      labelText: 'Set Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => setNameChanged = true),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cardNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Card Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        setState(() => cardNumberChanged = true),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Memo',
                      border: OutlineInputBorder(),
                      hintText: 'Enter a note',
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();

                  final String? rarity =
                      rarityChanged && rarityController.text.isEmpty
                          ? null
                          : (rarityChanged ? rarityController.text : null);
                  final String? setName =
                      setNameChanged && setNameController.text.isEmpty
                          ? null
                          : (setNameChanged ? setNameController.text : null);
                  final int? cardNumber = cardNumberChanged
                      ? int.tryParse(cardNumberController.text)
                      : null;

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
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}

