import 'package:cardpro/core/di/injection_container.dart';
import 'package:cardpro/db/database.dart';
import 'package:cardpro/features/decks/domain/entities/container.dart' as container_entity;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cardpro/features/containers/presentation/bloc/container_bloc.dart';
import 'package:cardpro/features/containers/presentation/bloc/container_event.dart';

class ContainerDetailPage extends StatefulWidget {
  final container_entity.Container container;

  const ContainerDetailPage({super.key, required this.container});

  @override
  State<ContainerDetailPage> createState() => _ContainerDetailPageState();
}

class _ContainerDetailPageState extends State<ContainerDetailPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _typeController;
  late Future<List<(MtgCard, CardInstance, ContainerCardLocation)>> _cardsFuture;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.container.name ?? '');
    _descriptionController = TextEditingController(text: widget.container.description ?? '');
    _typeController = TextEditingController(text: widget.container.containerType);
    _cardsFuture = sl<AppDatabase>().getCardsInDeck(widget.container.id);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.container.name ?? 'Container ${widget.container.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: '保存',
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
                  labelText: '名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: '種類（drawer, binder など）',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '説明',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              const Text(
                'このコンテナのカード',
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
                      child: Text('読み込みに失敗: ${snapshot.error}'),
                    );
                  }
                  final data = snapshot.data ?? const <(MtgCard, CardInstance, ContainerCardLocation)>[];
                  if (data.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('このコンテナにカードはありません'),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final (mtg, instance, link) = data[index];
                      return ListTile(
                        title: Text(mtg.name),
                        subtitle: Text('場所: ${link.location}'),
                        trailing: IconButton(
                          tooltip: 'コンテナから外す',
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () async {
                            await sl<AppDatabase>().removeCardFromDeck(
                              containerId: widget.container.id,
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
        onPressed: _showAddCardSheet,
        icon: const Icon(Icons.add),
        label: const Text('カードを追加'),
      ),
    );
  }

  void _onSave() {
    final name = _nameController.text.trim();
    final type = _typeController.text.trim();
    final desc = _descriptionController.text.trim();
    if (name.isEmpty || type.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('名称と種類は必須です')),
      );
      return;
    }

    // Dispatch edit via BLoC if available
    try {
      // ignore: use_build_context_synchronously
      // Accessing bloc to trigger update and then show feedback
      // We don't wait for completion here; the list page will refresh when re-entered.
      // In a more advanced setup, we could listen to state changes.
      // This keeps it simple and consistent with DeckDetail.
      // ignore: cascade_invocations
      context.read<ContainerBloc>().add(EditContainerEvent(
            id: widget.container.id,
            name: name,
            description: desc.isEmpty ? null : desc,
            containerType: type,
          ));
    } catch (_) {
      // no bloc found; ignore
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('保存しました')),
    );
  }

  void _refreshCards() {
    setState(() {
      _cardsFuture = sl<AppDatabase>().getCardsInDeck(widget.container.id);
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
                  return Text('候補の読み込みに失敗: ${snapshot.error}');
                }
                final available = snapshot.data ?? const <(MtgCard, CardInstance)>[];
                if (available.isEmpty) {
                  return const Text('追加できるカードがありません');
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'コンテナにカードを追加',
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
                                  containerId: widget.container.id,
                                  cardInstanceId: instance.id,
                                  location: 'storage',
                                );
                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                                _refreshCards();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('追加しました: ${mtg.name}')),
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
