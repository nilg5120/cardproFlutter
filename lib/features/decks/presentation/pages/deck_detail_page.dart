import 'package:cardpro/core/di/injection_container.dart';
import 'package:cardpro/db/database.dart';
import 'package:cardpro/features/decks/domain/entities/container.dart' as deck_entity;
import 'package:cardpro/features/decks/presentation/bloc/deck_bloc.dart';
import 'package:cardpro/features/decks/presentation/bloc/deck_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeckDetailPage extends StatefulWidget {
  final deck_entity.Container deck;

  const DeckDetailPage({super.key, required this.deck});

  @override
  State<DeckDetailPage> createState() => _DeckDetailPageState();
}

class _DeckDetailPageState extends State<DeckDetailPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late Future<List<(MtgCard, CardInstance, ContainerCardLocation)>> _cardsFuture;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.deck.name ?? '');
    _descriptionController = TextEditingController(text: widget.deck.description ?? '');
    _cardsFuture = sl<AppDatabase>().getCardsInDeck(widget.deck.id);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deck.name ?? 'Deck ${widget.deck.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: _onSave,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Deck Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              const Text(
                'Cards in Deck',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<(MtgCard, CardInstance, ContainerCardLocation)>>(
                future: _cardsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Failed to load cards: ${snapshot.error}'),
                    );
                  }
                  final data = snapshot.data ?? const <(MtgCard, CardInstance, ContainerCardLocation)>[];
                  if (data.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('No cards in this deck'),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final (mtg, instanceUnused, link) = data[index];
                      return ListTile(
                        title: Text(mtg.name),
                        subtitle: Text('Location: ${link.location}'),
                        trailing: IconButton(
                          tooltip: 'Remove from deck',
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () async {
                            await sl<AppDatabase>().removeCardFromDeck(
                              containerId: widget.deck.id,
                              cardInstanceId: link.cardInstanceId,
                            );
                            _refreshCards();
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'decks_fab_detail',
        onPressed: _showAddCardSheet,
        icon: const Icon(Icons.add),
        label: const Text('Add Card'),
      ),
    );
  }

  void _onSave() {
    final name = _nameController.text.trim();
    final desc = _descriptionController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deck name is required')),
      );
      return;
    }

    context.read<DeckBloc>().add(
          EditDeckEvent(
            id: widget.deck.id,
            name: name,
            description: desc.isEmpty ? null : desc,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deck saved')),
    );
  }

  void _refreshCards() {
    setState(() {
      _cardsFuture = sl<AppDatabase>().getCardsInDeck(widget.deck.id);
    });
  }

  Future<void> _showAddCardSheet() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<List<(MtgCard, CardInstance)>>(
              future: sl<AppDatabase>().getUnassignedCardInstances(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ));
                }
                if (snapshot.hasError) {
                  return Text('Failed to load available cards: ${snapshot.error}');
                }
                final available = snapshot.data ?? const <(MtgCard, CardInstance)>[];
                if (available.isEmpty) {
                  return const Text('No available cards to add');
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Card to Deck',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.separated(
                        itemCount: available.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final (mtg, instance) = available[index];
                          return ListTile(
                            title: Text(mtg.name),
                            subtitle: Text('Instance #${instance.id}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () async {
                                await sl<AppDatabase>().addCardToDeck(
                                  containerId: widget.deck.id,
                                  cardInstanceId: instance.id,
                                  location: 'main',
                                );
                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                                _refreshCards();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Added ${mtg.name}')),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
