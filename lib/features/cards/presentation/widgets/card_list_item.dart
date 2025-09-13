import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:flutter/material.dart';

class CardListItem extends StatelessWidget {
  final CardWithInstance card;
  final VoidCallback onDelete;
  final Function(String, {String? rarity, String? setName, int? cardNumber})
      onEdit;
  final VoidCallback? onTap;
  final bool showDelete;
  final bool showSetName;
  final bool showCardName;
  // Optional override for the title widget (e.g., localized name)
  final Widget? title;

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
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap ?? () => _showEditDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
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
                      ),
                    if (showCardName) const SizedBox(width: 12),
                    // Set name (optional)
                    if (showSetName && card.card.setName != null)
                      Text(
                        card.card.setName!,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey[700]),
                      ),
                  ],
                ),
              ),
            Row(
              children: [
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
