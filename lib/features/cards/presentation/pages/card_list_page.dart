import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_bloc.dart';
import 'package:cardpro/features/cards/presentation/widgets/card_list_item.dart';
import 'package:cardpro/core/di/injection_container.dart';
import 'package:cardpro/db/database.dart';

class CardListPage extends StatelessWidget {
  const CardListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CardBloc>()..add(GetCardsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('カード一覧'),
        ),
        body: BlocBuilder<CardBloc, CardState>(
          builder: (context, state) {
            if (state is CardLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CardLoaded) {
              return _buildCardList(context, state.cards);
            } else if (state is CardError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('カードを読み込んでください'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddCardDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildCardList(BuildContext context, List<CardWithInstance> cards) {
    if (cards.isEmpty) {
      return const Center(child: Text('カードがありません'));
    }

    return ListView.builder(
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return CardListItem(
          card: card,
          onDelete: () {
            context.read<CardBloc>().add(DeleteCardEvent(card.instance));
          },
          onEdit: (description, {String? rarity, String? setName, int? cardNumber}) {
            if (rarity != null || setName != null || cardNumber != null) {
              context.read<CardBloc>().add(
                    EditCardFullEvent(
                      card: card.card,
                      instance: card.instance,
                      rarity: rarity ?? card.card.rarity,
                      setName: setName ?? card.card.setName,
                      cardNumber: cardNumber ?? card.card.cardNumber,
                      description: description,
                    ),
                  );
            } else {
              context.read<CardBloc>().add(
                    EditCardEvent(
                      instance: card.instance,
                      description: description,
                    ),
                  );
            }
          },
        );
      },
    );
  }

  // ダイアログを表示して新しいカードを追加する
  void _showAddCardDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final rarityController = TextEditingController();
    final setNameController = TextEditingController();
    final cardNumberController = TextEditingController();
    
    // BlocProviderの子ウィジェットからBlocを取得
    // FloatingActionButtonのonPressedコールバック内でのcontextはScaffoldのコンテキストであり、
    // BlocProviderの子ウィジェットのコンテキストではないため、直接取得できない
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        // 新しいBlocProviderを作成して、依存性注入コンテナからBlocを取得
        return BlocProvider(
          create: (_) => sl<CardBloc>(),
          child: Builder(
            builder: (builderContext) {
              // カード効果のリストを取得
              final database = sl<AppDatabase>();
              return FutureBuilder<List<CardEffect>>(
                future: database.getAllCardEffects(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const AlertDialog(
                      content: Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  final cardEffects = snapshot.data ?? [];
                  int selectedEffectId = cardEffects.isNotEmpty ? cardEffects.first.id : 1;
                  
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: const Text('カードを追加'),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: nameController,
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
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: setNameController,
                                decoration: const InputDecoration(
                                  labelText: '拡張パック名',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: cardNumberController,
                                decoration: const InputDecoration(
                                  labelText: 'カード番号',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<int>(
                                decoration: const InputDecoration(
                                  labelText: 'カード効果',
                                  border: OutlineInputBorder(),
                                ),
                                value: selectedEffectId,
                                items: cardEffects.map((effect) {
                                  return DropdownMenuItem<int>(
                                    value: effect.id,
                                    child: Text('${effect.name} - ${effect.description}'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedEffectId = value;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: descriptionController,
                                decoration: const InputDecoration(
                                  labelText: '説明',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('キャンセル'),
                          ),
                          TextButton(
                            onPressed: () {
                              final name = nameController.text;
                              if (name.isNotEmpty) {
                                // 新しいコンテキストからBlocを取得
                                builderContext.read<CardBloc>().add(
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
                                Navigator.of(dialogContext).pop();
                              }
                            },
                            child: const Text('追加'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
