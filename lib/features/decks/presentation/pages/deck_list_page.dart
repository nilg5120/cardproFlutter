import 'package:cardpro/core/di/injection_container.dart';
import 'package:cardpro/features/decks/domain/entities/container.dart' as deck_entity;
import 'package:cardpro/features/decks/presentation/bloc/deck_bloc.dart';
import 'package:cardpro/features/decks/presentation/bloc/deck_event.dart';
import 'package:cardpro/features/decks/presentation/widgets/deck_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeckListPage extends StatelessWidget {
  const DeckListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DeckBloc>()..add(GetDecksEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Decks'),
        ),
        body: BlocBuilder<DeckBloc, DeckState>(
          builder: (context, state) {
            if (state is DeckLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DeckLoaded) {
              return _buildDeckList(context, state.decks);
            } else if (state is DeckError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Please load decks'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddDeckDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildDeckList(BuildContext context, List<deck_entity.Container> decks) {
    if (decks.isEmpty) {
      return const Center(child: Text('No decks'));
    }

    return ListView.builder(
      itemCount: decks.length,
      itemBuilder: (context, index) {
        final deck = decks[index];
        return DeckListItem(
          deck: deck,
          onDelete: () {
            context.read<DeckBloc>().add(DeleteDeckEvent(id: deck.id));
          },
          onEdit: (String? name, String? description) {
            context.read<DeckBloc>().add(
              EditDeckEvent(
                id: deck.id,
                name: name ?? deck.name ?? "",
                description: description,
              ),
            );
          },
        );
      },
    );
  }

  void _showAddDeckDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Deck'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Deck Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  context.read<DeckBloc>().add(
                        AddDeckEvent(
                          name: nameController.text,
                          description: descriptionController.text.isNotEmpty
                              ? descriptionController.text
                              : null,
                        ),
                      );
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

