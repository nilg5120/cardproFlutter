import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'db/database.dart';

class DeckFormPage extends StatefulWidget {
  final AppDatabase db;

  const DeckFormPage({super.key, required this.db});

  @override
  State<DeckFormPage> createState() => _DeckFormPageState();
}

class _DeckFormPageState extends State<DeckFormPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await widget.db.into(widget.db.containers).insert(
      ContainersCompanion.insert(
        name: drift.Value(nameController.text),
        description: drift.Value(descriptionController.text),
        containerType: 'deck',
      ),
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('デッキを追加')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'デッキ名'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? '必須項目です' : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: '説明'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: const Text('保存'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
