import 'package:cardpro/features/cards/presentation/widgets/add_card_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_bloc.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_event.dart';
import 'package:cardpro/features/cards/presentation/widgets/card_list_item.dart';
import 'package:cardpro/core/di/injection_container.dart';

class CardListPage extends StatelessWidget {
  const CardListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 既存のBlocProviderがあるかチェック
    try {
      // 既存のBlocProviderがある場合はそれを使用
      BlocProvider.of<CardBloc>(context, listen: false);
      return _buildScaffold(context);
    } catch (_) {
      // 既存のBlocProviderがない場合は新しく作成
      return BlocProvider(
        create: (_) => sl<CardBloc>()..add(GetCardsEvent()),
        child: _buildScaffold(context),
      );
    }
  }
  
  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
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
  void _showAddCardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CardBloc>(),
        child: const AddCardDialog(),
      ),
    );
  }
}
