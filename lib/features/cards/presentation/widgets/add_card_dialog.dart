import 'package:cardpro/core/di/injection_container.dart';
import 'package:cardpro/db/database.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_bloc.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddCardDialog extends StatefulWidget {
  const AddCardDialog({super.key});

  @override
  State<AddCardDialog> createState() => _AddCardDialogState();
}

class _AddCardDialogState extends State<AddCardDialog> {
  // Text controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final rarityController = TextEditingController();
  final setNameController = TextEditingController();
  final cardNumberController = TextEditingController();

  // Selected card effect id
  int selectedEffectId = 1;

  late Future<List<CardEffect>> cardEffectsFuture;

  @override
  void initState() {
    super.initState();
    final database = sl<AppDatabase>();
    cardEffectsFuture = database.getAllCardEffects();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    rarityController.dispose();
    setNameController.dispose();
    cardNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CardEffect>>(
      future: cardEffectsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AlertDialog(
            content: Center(child: CircularProgressIndicator()),
          );
        }

        final cardEffects = snapshot.data ?? [];
        if (cardEffects.isNotEmpty && !cardEffects.any((e) => e.id == selectedEffectId)) {
          selectedEffectId = cardEffects.first.id;
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Card'),
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
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: rarityController,
                      decoration: const InputDecoration(
                        labelText: 'Rarity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: setNameController,
                      decoration: const InputDecoration(
                        labelText: 'Set Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: cardNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Card Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Effect',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedEffectId,
                      items: cardEffects
                          .map((effect) => DropdownMenuItem<int>(
                                value: effect.id,
                                child: Text('${effect.name} - ${effect.description}'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedEffectId = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
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
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final name = nameController.text;
                    if (name.isNotEmpty) {
                      context.read<CardBloc>().add(
                            AddCardEvent(
                              name: name,
                              rarity: rarityController.text.isNotEmpty ? rarityController.text : null,
                              setName: setNameController.text.isNotEmpty ? setNameController.text : null,
                              cardNumber: int.tryParse(cardNumberController.text),
                              effectId: selectedEffectId,
                              description: descriptionController.text.isNotEmpty
                                  ? descriptionController.text
                                  : null,
                            ),
                          );
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

