import 'package:flutter/material.dart';

class EditCardDialog extends StatefulWidget {
  final String name;
  final String? rarity;
  final String? setName;
  final int? cardNumber;
  final String? description;
  final void Function(String description, {String? rarity, String? setName, int? cardNumber}) onSave;

  const EditCardDialog({
    super.key,
    required this.name,
    required this.onSave,
    this.rarity,
    this.setName,
    this.cardNumber,
    this.description,
  });

  @override
  State<EditCardDialog> createState() => _EditCardDialogState();
}

class _EditCardDialogState extends State<EditCardDialog> {
  late TextEditingController nameController;
  late TextEditingController rarityController;
  late TextEditingController setNameController;
  late TextEditingController cardNumberController;
  late TextEditingController descriptionController;

  bool rarityChanged = false;
  bool setNameChanged = false;
  bool cardNumberChanged = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    rarityController = TextEditingController(text: widget.rarity ?? '');
    setNameController = TextEditingController(text: widget.setName ?? '');
    cardNumberController = TextEditingController(text: widget.cardNumber?.toString() ?? '');
    descriptionController = TextEditingController(text: widget.description ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    rarityController.dispose();
    setNameController.dispose();
    cardNumberController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('カード情報を編集'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'カード名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: rarityController,
              decoration: const InputDecoration(
                labelText: 'レアリティ',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() => rarityChanged = true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: setNameController,
              decoration: const InputDecoration(
                labelText: '拡張パック名',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() => setNameChanged = true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cardNumberController,
              decoration: const InputDecoration(
                labelText: 'カード番号',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() => cardNumberChanged = true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'メモ',
                border: OutlineInputBorder(),
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

            final String? rarity = rarityChanged && rarityController.text.isNotEmpty ? rarityController.text : null;
            final String? setName = setNameChanged && setNameController.text.isNotEmpty ? setNameController.text : null;
            final int? cardNumber = cardNumberChanged ? int.tryParse(cardNumberController.text) : null;

            widget.onSave(
              descriptionController.text,
              rarity: rarity,
              setName: setName,
              cardNumber: cardNumber,
            );
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
