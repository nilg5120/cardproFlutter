import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'db/database.dart';

class CardFormPage extends StatefulWidget {
  final AppDatabase db;
  const CardFormPage({super.key, required this.db});

  @override
  State<CardFormPage> createState() => _CardFormPageState();
}

class _CardFormPageState extends State<CardFormPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final setNameController = TextEditingController();
  final cardNumberController = TextEditingController();
  final rarityController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    setNameController.dispose();
    cardNumberController.dispose();
    rarityController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // カードマスター登録
    final master = PokemonCardsCompanion.insert(
      name: nameController.text,
      rarity: drift.Value(rarityController.text),
      setName: drift.Value(setNameController.text),
      cardnumber: drift.Value(int.tryParse(cardNumberController.text)),
    );

    final inserted = await widget.db.into(widget.db.pokemonCards).insertReturning(master);

    // カード個体登録
    await widget.db.into(widget.db.cardInstances).insert(
      CardInstancesCompanion.insert(
        cardId: inserted.id,
        description: drift.Value(descriptionController.text),
      ),
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('カードを登録')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'カード名'),
                validator: (value) => value == null || value.isEmpty ? '必須項目です' : null,
              ),
              TextFormField(
                controller: setNameController,
                decoration: const InputDecoration(labelText: '拡張パック名'),
              ),
              TextFormField(
                controller: cardNumberController,
                decoration: const InputDecoration(labelText: 'カード番号'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: rarityController,
                decoration: const InputDecoration(labelText: 'レアリティ'),
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: '説明（個体情報）'),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
