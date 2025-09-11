import 'package:cardpro/core/di/injection_container.dart';
import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_bloc.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_event.dart';
import 'package:cardpro/features/cards/presentation/widgets/add_card_dialog.dart';
import 'package:cardpro/features/cards/presentation/widgets/card_list_item.dart';
import 'package:cardpro/features/cards/presentation/pages/card_instances_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CardListPage extends StatelessWidget {
  const CardListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 上位ツリーに既存の BlocProvider があればそれを利用する
    try {
      BlocProvider.of<CardBloc>(context, listen: false);
      return _buildScaffold(context);
    } catch (_) {
      // なければローカルに BlocProvider を作成する
      return BlocProvider(
        create: (_) => sl<CardBloc>()..add(GetCardsEvent()),
        child: _buildScaffold(context),
      );
    }
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cards'),
      ),
      body: BlocBuilder<CardBloc, CardState>(
        builder: (context, state) {
          if (state is CardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CardLoaded) {
            return _buildCardList(context, state.cards);
          } else if (state is CardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CardBloc>().add(GetCardsEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is CardInitial) {
            // 初回フレーム描画後に読み込みをトリガーする
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<CardBloc>().add(GetCardsEvent());
            });
            return const Center(child: CircularProgressIndicator());
          }

          return const Center(child: Text('カードを読み込んでください'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'cards_fab',
        onPressed: () => _showAddCardDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCardList(BuildContext context, List<CardWithInstance> items) {
    if (items.isEmpty) {
      return const Center(child: Text('カードがありません'));
    }

    // カード名ごとにグルーピング
    final Map<String, List<CardWithInstance>> byName = {};
    for (final e in items) {
      byName.putIfAbsent(e.card.name, () => []).add(e);
    }
    final grouped = byName.values.toList();

    return ListView.builder(
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final group = grouped[index];
        final representative = group.first; // use first instance for display
        // タイトルは代表カードの名前
        final title = representative.card.name;

        return CardListItem(
          card: representative,
          // Navigate to instances list when tapped
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<CardBloc>(),
                  child: CardInstancesPage(
                    title: title,
                    instances: group,
                  ),
                ),
              ),
            );
          },
          // Hide delete button on grouped list
          showDelete: false,
          // セット名は一覧では非表示（セットが混在するため）
          showSetName: false,
          // Keep handlers to satisfy constructor but won't be visible/used
          onDelete: () {},
          onEdit: (_, {String? rarity, String? setName, int? cardNumber}) {},
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
