import 'package:cardpro/core/di/injection_container.dart';
import 'package:cardpro/db/database.dart' as db;
import 'package:cardpro/features/cards/domain/entities/card_instance.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance_location.dart';
import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_bloc.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_event.dart';
import 'package:cardpro/features/cards/presentation/widgets/card_list_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Card instance list screen
class CardInstancesPage extends StatefulWidget {
  final String title;
  final List<CardWithInstance> instances;

  const CardInstancesPage({super.key, required this.title, required this.instances});

  @override
  State<CardInstancesPage> createState() => _CardInstancesPageState();
}

class _CardInstancesPageState extends State<CardInstancesPage> {
  late List<CardWithInstance> _instances;

  @override
  void initState() {
    super.initState();
    _instances = List<CardWithInstance>.from(widget.instances);
  }

  @override
  void didUpdateWidget(CardInstancesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.instances, widget.instances)) {
      _instances = List<CardWithInstance>.from(widget.instances);
    }
  }

  @override
  Widget build(BuildContext context) {
    final widgetBody = _instances.isEmpty
        ? const Center(child: Text('カードインスタンスはまだありません'))
        : _buildGroupedList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: widgetBody,
    );
  }

  Widget _buildGroupedList() {
    final Map<String, List<CardWithInstance>> bySet = {};
    for (final it in _instances) {
      final key = it.card.setName?.trim().isNotEmpty == true
          ? it.card.setName!.trim()
          : 'Unknown Set';
      bySet.putIfAbsent(key, () => []).add(it);
    }
    final setNames = bySet.keys.toList()..sort((a, b) => a.compareTo(b));

    return ListView.builder(
      itemCount: setNames.length,
      itemBuilder: (context, sectionIndex) {
        final setName = setNames[sectionIndex];
        final group = bySet[setName]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                setName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final item in group)
              CardListItem(
                card: item,
                // Hide card/set names in grouped view
                showCardName: false,
                showSetName: false,
                onTap: () => _showInstanceEditDialog(item),
                onDelete: () => _handleDelete(item),
                onEdit: (description, {String? rarity, String? setName, int? cardNumber}) {
                  context.read<CardBloc>().add(
                        EditCardEvent(
                          instance: item.instance,
                          description: description,
                        ),
                      );
                },
              ),
          ],
        );
      },
    );
  }

  Future<void> _showInstanceEditDialog(CardWithInstance item) async {
    final database = sl<db.AppDatabase>();
    final containers = await (database.select(database.containers)).get();

    if (!mounted) {
      return;
    }

    final memoController = TextEditingController(text: item.instance.description ?? '');
    final currentPlacement = item.placements.isNotEmpty ? item.placements.first : null;
    final locationController =
        TextEditingController(text: currentPlacement?.location ?? 'main');
    int? selectedContainerId = currentPlacement?.containerId;
    bool isSaving = false;
    String? errorMessage;

    final result = await showDialog<_InstanceUpdateResult>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('カードインスタンスを編集'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: memoController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'メモ',
                        hintText: '任意のメモを入力',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int?>(
                      value: selectedContainerId,
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('未割り当て'),
                        ),
                        ...containers.map(
                          (container) => DropdownMenuItem<int?>(
                            value: container.id,
                            child: Text(
                              (container.name != null &&
                                      container.name!.trim().isNotEmpty)
                                  ? container.name!.trim()
                                  : '${container.containerType} #${container.id}',
                            ),
                          ),
                        ),
                      ],
                      onChanged: isSaving
                          ? null
                          : (value) {
                              final previousId = selectedContainerId;
                              setState(() {
                                selectedContainerId = value;
                                errorMessage = null;
                                if (value == null) {
                                  locationController.text = '';
                                } else if (value != previousId) {
                                  if (value == currentPlacement?.containerId) {
                                    locationController.text =
                                        currentPlacement?.location ?? 'main';
                                  } else {
                                    locationController.text = 'main';
                                  }
                                }
                              });
                            },
                      decoration: const InputDecoration(
                        labelText: 'コンテナ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: locationController,
                      enabled: !isSaving && selectedContainerId != null,
                      decoration: const InputDecoration(
                        labelText: 'ロケーション',
                        hintText: '例: main, side, Slot A',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                        },
                  child: const Text('キャンセル'),
                ),
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final memo = memoController.text;
                          final selectedId = selectedContainerId;
                          final originalMemo = item.instance.description ?? '';
                          final originalLocation = currentPlacement?.location ?? '';
                          final trimmedLocation = locationController.text.trim();

                          final bool placementChanged =
                              (selectedId ?? -1) != (currentPlacement?.containerId ?? -1) ||
                                  (selectedId != null && trimmedLocation != originalLocation);

                          if (!placementChanged && memo == originalMemo) {
                            Navigator.of(dialogContext).pop();
                            return;
                          }

                          db.Container? selectedContainer;
                          String? location;

                          if (selectedId != null) {
                            if (trimmedLocation.isEmpty) {
                              setState(() {
                                errorMessage = 'ロケーションを入力してください';
                              });
                              return;
                            }
                            selectedContainer = containers
                                .firstWhere((element) => element.id == selectedId);
                            location = trimmedLocation;
                          }

                          setState(() {
                            isSaving = true;
                            errorMessage = null;
                          });

                          try {
                            if (placementChanged) {
                              await _applyContainerChange(
                                item,
                                selectedContainer,
                                location,
                              );
                            }

                            if (!mounted) {
                              return;
                            }

                            if (memo != originalMemo) {
                              context.read<CardBloc>().add(
                                    EditCardEvent(
                                      instance: item.instance,
                                      description: memo,
                                    ),
                                  );
                            } else if (placementChanged) {
                              context.read<CardBloc>().add(GetCardsEvent());
                            }

                            Navigator.of(dialogContext).pop(
                              _InstanceUpdateResult(
                                description: memo,
                                container: selectedContainer,
                                location:
                                    selectedId != null ? (location ?? trimmedLocation) : null,
                              ),
                            );
                          } catch (error) {
                            setState(() {
                              errorMessage = '保存に失敗しました: $error';
                              isSaving = false;
                            });
                          }
                        },
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );

    memoController.dispose();
    locationController.dispose();

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _instances = _instances
          .map(
            (entry) => entry.instance.id == item.instance.id
                ? CardWithInstance(
                    card: entry.card,
                    instance: CardInstance(
                      id: entry.instance.id,
                      cardId: entry.instance.cardId,
                      updatedAt: entry.instance.updatedAt,
                      description: result.description,
                    ),
                    placements: result.container == null
                        ? const []
                        : [
                            CardInstanceLocation(
                              containerId: result.container!.id,
                              containerName: result.container!.name,
                              containerDescription:
                                  result.container!.description,
                              containerType: result.container!.containerType,
                              isActive: result.container!.isActive,
                              location: result.location ?? 'main',
                            ),
                          ],
                  )
                : entry,
          )
          .toList();
    });
  }

  Future<void> _applyContainerChange(
    CardWithInstance item,
    db.Container? container,
    String? location,
  ) async {
    final database = sl<db.AppDatabase>();

    for (final placement in item.placements) {
      await database.removeCardFromDeck(
        containerId: placement.containerId,
        cardInstanceId: item.instance.id,
      );
    }

    if (container != null && location != null) {
      await database.addCardToDeck(
        containerId: container.id,
        cardInstanceId: item.instance.id,
        location: location,
      );
    }
  }

  void _handleDelete(CardWithInstance item) {
    context.read<CardBloc>().add(DeleteCardEvent(item.instance));
    setState(() {
      _instances.removeWhere((element) => element.instance.id == item.instance.id);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('削除が完了しました'),
          content: const Text('カードを削除しました。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }
}

class _InstanceUpdateResult {
  final String description;
  final db.Container? container;
  final String? location;

  const _InstanceUpdateResult({
    required this.description,
    required this.container,
    required this.location,
  });
}
