import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_bloc.dart';
import 'package:cardpro/features/cards/presentation/widgets/card_list_item.dart';
import 'package:cardpro/core/di/injection_container.dart';

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
          onEdit: (description) {
            context.read<CardBloc>().add(
                  EditCardEvent(
                    instance: card.instance,
                    description: description,
                  ),
                );
          },
        );
      },
    );
  }
}
